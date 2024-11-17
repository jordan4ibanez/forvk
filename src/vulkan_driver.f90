module vulkan_driver
  use, intrinsic :: iso_c_binding
  use :: glfw
  use :: string_f90
  use :: vector
  use :: forvulkan
  use :: forvulkan_parameters
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
  use :: vulkan_driver_create_graphics_pipeline
  implicit none

  ! https://github.com/KhronosGroup/Vulkan-Headers/blob/main/include/vulkan/vulkan_core.h

  ! Treating this thing as a class to follow the vulkan tutorial.
  ! todo: in formine this will have a pointer struct which inherits from a base class, to direct traffic flow to these functions.
  !
  ! todo: this has a lot of memory leaks which will need to be tested with valgrind to fix.


  ! VkInstance
  integer(c_int64_t), target :: vulkan_instance = VK_NULL_HANDLE

  ! VkDebugUtilsMessengerEXT
  integer(c_int64_t), target :: debug_messenger = VK_NULL_HANDLE

  ! VkSurfaceKHR
  integer(c_int64_t), target :: window_surface = VK_NULL_HANDLE

  ! VkPhysicalDevice
  integer(c_int64_t), target :: physical_device = VK_NULL_HANDLE

  ! VkDevice
  integer(c_int64_t), target :: logical_device = VK_NULL_HANDLE

  ! VkQueue
  integer(c_int64_t), target :: graphics_queue = VK_NULL_HANDLE

  ! VkQueue
  integer(c_int64_t), target :: present_queue = VK_NULL_HANDLE

  ! VkSwapchainKHR
  integer(c_int64_t), target :: swapchain = VK_NULL_HANDLE

  ! VkImage Array
  type(vec) :: swapchain_images

  ! VkFormat
  integer(c_int32_t) :: swapchain_image_format = 0

  ! VkExtent2D
  type(vk_extent_2d) :: swapchain_extent

  ! VkImageView Array
  type(vec) :: swapchain_image_views

  ! VkShaderModule
  integer(c_int64_t) :: vertex_shader_module

  ! VkShaderModule
  integer(c_int64_t) :: fragment_shader_module

  ! VkPipelineLayout
  integer(c_int64_t) :: pipeline_layout

  ! VkRenderPass
  integer(c_int64_t) :: render_pass

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

    call create_graphics_pipeline(logical_device, vertex_shader_module, fragment_shader_module, swapchain_extent, pipeline_layout)

    call create_render_pass(render_pass)

  end subroutine init_vulkan


  subroutine create_render_pass(render_pass)
    implicit none

    ! VkRenderPass
    integer(c_int64_t), intent(inout) :: render_pass
    type(vk_attachment_description), target :: color_attachment_description
    type(vk_attachment_reference), target :: color_attachment_reference
    type(vk_subpass_description_t), target :: subpass
    type(vk_render_pass_create_info), target  :: render_pass_create_info

    color_attachment_description%format = swapchain_image_format
    color_attachment_description%samples = VK_SAMPLE_COUNT_1_BIT
    color_attachment_description%load_op = VK_ATTACHMENT_LOAD_OP_CLEAR
    color_attachment_description%store_op = VK_ATTACHMENT_STORE_OP_STORE
    color_attachment_description%stencil_load_op = VK_ATTACHMENT_LOAD_OP_DONT_CARE
    color_attachment_description%stencil_store_op = VK_ATTACHMENT_STORE_OP_DONT_CARE
    color_attachment_description%initial_layout = VK_IMAGE_LAYOUT_UNDEFINED
    color_attachment_description%final_layout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR

    color_attachment_reference%attachment = 0
    color_attachment_reference%layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL

    subpass%pipeline_bind_point = VK_PIPELINE_BIND_POINT_GRAPHICS
    subpass%color_attachment_count = 1
    subpass%p_color_attachments = c_loc(color_attachment_reference)

    render_pass_create_info%s_type = VK_STRUCTURE_TYPE%RENDER_PASS_CREATE_INFO
    render_pass_create_info%attachment_count = 1
    render_pass_create_info%p_attachments = c_loc(color_attachment_description)
    render_pass_create_info%subpass_count = 1
    render_pass_create_info%p_subpasses = c_loc(subpass)

  end subroutine create_render_pass





!* MAIN LOOP. ====================================================================


  subroutine main_loop()
    implicit none

    ! do while(.not. glfw_window_should_close())
    !   call glfw_poll_events()
    ! end do

  end subroutine main_loop


!* CLEAN UP. ====================================================================

  subroutine clean_up()
    implicit none

    integer(c_int64_t) :: i
    integer(c_int64_t), pointer :: image_view

    call vk_destroy_pipeline_layout(logical_device, pipeline_layout, c_null_ptr)

    do i = 1,swapchain_image_views%size()
      call c_f_pointer(swapchain_image_views%get(i), image_view)
      call vk_destroy_image_view(logical_device, image_view, c_null_ptr)
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
