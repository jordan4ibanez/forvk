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

  ! VkPhysicalDevice
  integer(c_int64_t), target :: physical_device = VK_NULL_HANDLE

  ! VkDevice
  integer(c_int64_t), target :: logical_device = VK_NULL_HANDLE

  ! VkSurfaceKHR
  integer(c_int64_t), target :: window_surface = VK_NULL_HANDLE

  ! VkQueue
  integer(c_int64_t), target :: graphics_queue = VK_NULL_HANDLE

  ! VkQueue
  integer(c_int64_t), target :: present_queue = VK_NULL_HANDLE

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
!   !! NOTICE: Redirecting the pointer with c_f_pointer here!
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

    call query_swap_chain_support(physical_device, window_surface)

  end subroutine init_vulkan


  subroutine query_swap_chain_support(physical_device, window_surface)
    implicit none

    ! VkPhysicalDevice
    integer(c_int64_t), intent(in), value :: physical_device
    ! VkSurfaceKHR
    integer(c_int64_t), intent(in), value :: window_surface
    logical(c_bool) :: has_swap_chain_support
    type(forvulkan_swap_chain_support_details), pointer :: swap_chain_support_details
    integer(c_int32_t) :: format_count, present_mode_count
    type(vk_surface_format_khr), pointer :: surface_format_pointer


    has_swap_chain_support = .true.

    allocate(swap_chain_support_details)

    ! First, get device surface capabilities.
    if (vk_get_physical_device_surface_capabilities_khr(physical_device, window_surface, c_loc(swap_chain_support_details%capabilities)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to get physical device surface capabilities."
    end if

    ! Next, we must get the available device window surface formats.
    if (vk_get_physical_device_surface_formats_khr(physical_device, window_surface, format_count, c_null_ptr) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to get available physical device surface formats."
    end if

    ! If it has none, well, we tried.
    if (format_count == 0) then
      print"(A)","[Vulkan]: Device has no surface formats."
      has_swap_chain_support = .false.
      return
    end if

    ! And if it does, we can get all of them.
    allocate(surface_format_pointer)
    swap_chain_support_details%formats = new_vec(sizeof(surface_format_pointer), 0_8)
    call swap_chain_support_details%formats%resize(int(format_count, c_int64_t), surface_format_pointer)
    deallocate(surface_format_pointer)

    ! We're passing in the underlying C array pointer.
    if (vk_get_physical_device_surface_formats_khr(physical_device, window_surface, format_count, swap_chain_support_details%formats%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to get available physical device surface formats."
    end if

    ! Now, we must get the present modes
    if (vk_get_physical_device_surface_present_modes_khr(physical_device, window_surface, present_mode_count, c_null_ptr) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to get avilable physical device surface present modes."
    end if

    ! If it has no surface present modes, welp, I guess that's that.
    if (present_mode_count == 0) then
      print"(A)","[Vulkan]: Device has no surface present modes."
      has_swap_chain_support = .false.
      return
    end if

    ! Again, if it does, we can get all of them.
    swap_chain_support_details%present_modes = new_vec(sizeof(0_4), 0_8)
    call swap_chain_support_details%present_modes%resize(int(present_mode_count, c_int64_t), 0_4)

    ! todo: something (very detailed)
  end subroutine query_swap_chain_support





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
