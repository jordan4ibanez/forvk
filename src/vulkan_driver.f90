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
  use :: vulkan_driver_create_swap_chain
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

    call create_swap_chain(physical_device, window_surface)

  end subroutine init_vulkan





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
