module vulkan_driver
  use, intrinsic :: iso_c_binding
  use :: glfw
  use :: string_f90
  use :: vector
  use :: forvulkan
  !? These are imported in the order of the steps this takes.
  use :: vulkan_driver_create_base
  use :: vulkan_driver_ensure_extensions_present
  use :: vulkan_driver_ensure_validation_layers
  use :: vulkan_driver_create_instance
  use :: vulkan_driver_create_debug_messenger
  use :: vulkan_driver_create_surface
  use :: vulkan_driver_select_physical_device
  use :: vulkan_driver_create_logical_device
  use :: vulkan_driver_create_swapchain
  use :: vulkan_driver_create_image_views
  use :: vulkan_driver_create_render_pass
  use :: vulkan_driver_create_graphics_pipeline
  use :: vulkan_driver_create_framebuffers
  use :: vulkan_driver_create_command_pool
  use :: vulkan_driver_create_command_buffer
  use :: vulkan_driver_create_sync_objects
  !? Then after this, it's just helpers.
  use :: vulkan_driver_record_command_buffer
  use :: vulkan_driver_draw_frame
  implicit none

  ! https://github.com/KhronosGroup/Vulkan-Headers/blob/main/include/vulkan/vulkan_core.h

  ! Treating this thing as a class to follow the vulkan tutorial.
  ! todo: in formine this will have a pointer struct which inherits from a base class, to direct traffic flow to these functions.


  type(vk_instance) :: vulkan_instance

  type(vk_debug_utils_messenger_ext) :: debug_messenger

  type(vk_surface_khr) :: window_surface

  type(vk_physical_device) :: physical_device

  type(vk_device) :: logical_device

  type(vk_queue) :: graphics_queue

  type(vk_queue) :: present_queue

  type(vk_swapchain_khr) :: swapchain

  ! Vk Image Vector
  type(vec) :: swapchain_images

  type(vk_format) :: swapchain_image_format

  type(vk_extent_2d) :: swapchain_extent

  ! Vk ImageView Vector
  type(vec) :: swapchain_image_views

  type(vk_shader_module) :: vertex_shader_module

  type(vk_shader_module) :: fragment_shader_module

  type(vk_pipeline_layout) :: pipeline_layout

  type(vk_render_pass) :: render_pass

  type(vk_pipeline) :: graphics_pipeline

  ! VkFramebuffer
  type(vec) :: swapchain_framebuffers

  ! VkCommandPool
  integer(c_int64_t) :: command_pool = VK_NULL_HANDLE

  ! VkCommandBuffer
  type(vec) :: command_buffers

  ! VkSemaphore
  type(vec) :: image_available_semaphores

  ! VkSemaphore
  type(vec) :: render_finished_semaphores

  ! VkFence
  type(vec) :: in_flight_fences

  !? This is the frame we're currently on.
  integer(c_int64_t) :: current_frame = 1

  !? How many frames should be processed concurrently.
  integer(c_int64_t), parameter :: MAX_FRAMES_IN_FLIGHT = 2

  ! Controls debugging output.
  logical(c_bool), parameter :: DEBUG_MODE = .true.


contains

  subroutine vulkan_run()
    implicit none

    call init_vulkan()
    call main_loop()
    call clean_up()
  end subroutine vulkan_run


!? This is how to get from these vectors. (char ** array underneath)
!? do i = 1,int(validation_layers%size())
!! NOTICE: Redirecting the pointer with c_f_pointer here!
!?   call c_f_pointer(validation_layers%get(int(i, c_int64_t)), raw_c_ptr_ptr)
!?   required_layer => string_from_c(raw_c_ptr_ptr)
!?   print*,required_layer
!? end do


!* INITIALIZATION. ====================================================================


  subroutine init_vulkan()
    implicit none

    call create_glfw()

    call ensure_extensions_present(DEBUG_MODE)

    call ensure_validation_layer_support(DEBUG_MODE)

    call create_vulkan_instance(vulkan_instance, DEBUG_MODE)

    call setup_debug_messenger(vulkan_instance, debug_messenger, DEBUG_MODE)

    call create_surface(vulkan_instance, window_surface)

    call select_physical_device(vulkan_instance, physical_device, window_surface)

    call create_logical_device(physical_device, logical_device, graphics_queue, present_queue, window_surface, DEBUG_MODE)

    call create_swapchain(physical_device, logical_device, window_surface, swapchain, swapchain_images, swapchain_image_format, swapchain_extent)

    call create_image_views(logical_device, swapchain_images, swapchain_image_views, swapchain_image_format)

    call create_render_pass(logical_device, render_pass, swapchain_image_format)

    call create_graphics_pipeline(logical_device, vertex_shader_module, fragment_shader_module, swapchain_extent, pipeline_layout, render_pass, graphics_pipeline)

    call create_framebuffers(logical_device, swapchain_framebuffers, swapchain_image_views, render_pass, swapchain_extent)

    call create_command_pool(physical_device, window_surface, logical_device, command_pool)

    call create_command_buffers(logical_device, MAX_FRAMES_IN_FLIGHT, command_pool, command_buffers)

    call create_sync_objects(logical_device, MAX_FRAMES_IN_FLIGHT, image_available_semaphores, render_finished_semaphores, in_flight_fences)

  end subroutine init_vulkan


!* MAIN LOOP. ====================================================================


  subroutine main_loop()
    implicit none

    integer(c_int32_t) :: a

    a = 0

    do while(.not. glfw_window_should_close())
      call glfw_poll_events()
      call draw_frame(logical_device, current_frame, MAX_FRAMES_IN_FLIGHT, in_flight_fences, image_available_semaphores, render_finished_semaphores, swapchain, command_buffers, render_pass, swapchain_framebuffers, swapchain_extent, graphics_pipeline, graphics_queue, present_queue)

      if (a >= 100) then
        call glfw_close_window()
      end if

      a = a + 1
    end do

    if (vk_device_wait_idle(logical_device) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to wait idle on logical device."
    end if

  end subroutine main_loop


!* CLEAN UP. ====================================================================

  subroutine clean_up()
    implicit none

    integer(c_int64_t) :: i
    type(vk_image_view), pointer :: image_view_pointer
    integer(c_int64_t), pointer :: framebuffer, semaphore, fence

    do i = 1,MAX_FRAMES_IN_FLIGHT
      call c_f_pointer(image_available_semaphores%get(i), semaphore)
      call vk_destroy_semaphore(logical_device, semaphore, c_null_ptr)

      call c_f_pointer(render_finished_semaphores%get(i), semaphore)
      call vk_destroy_semaphore(logical_device, semaphore, c_null_ptr)

      call c_f_pointer(in_flight_fences%get(i), fence)
      call vk_destroy_fence(logical_device, fence, c_null_ptr)
    end do

    call vk_destroy_command_pool(logical_device, command_pool, c_null_ptr)

    do i = 1,swapchain_framebuffers%size()
      call c_f_pointer(swapchain_framebuffers%get(i), framebuffer)
      call vk_destroy_framebuffer(logical_device, framebuffer, c_null_ptr)
    end do

    call vk_destroy_pipeline(logical_device, graphics_pipeline, c_null_ptr)

    call vk_destroy_pipeline_layout(logical_device, pipeline_layout, c_null_ptr)

    call vk_destroy_render_pass(logical_device, render_pass, c_null_ptr)

    do i = 1,swapchain_image_views%size()
      call c_f_pointer(swapchain_image_views%get(i), image_view_pointer)
      call vk_destroy_image_view(logical_device, image_view_pointer, c_null_ptr)
    end do

    call vk_destroy_swapchain_khr(logical_device, swapchain, c_null_ptr)

    call vk_destroy_surface_khr(vulkan_instance, window_surface, c_null_ptr)

    call vk_destroy_device(logical_device, c_null_ptr)

    if (DEBUG_MODE) then
      call forvulkan_destroy_debug_utils_messenger_ext(vulkan_instance, debug_messenger, c_null_ptr)
    end if

    print"(A)","[Vulkan]: Destroying instance."

    call vk_destroy_instance(vulkan_instance, c_null_ptr)

    call glfw_destroy_window()

    call glfw_terminate()

  end subroutine clean_up


end module vulkan_driver
