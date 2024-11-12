module vulkan_driver_query_swap_chain_support
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  use :: string_f90
  use :: vector
  implicit none


contains


  function query_swap_chain_support(physical_device, window_surface, swap_chain_support_details) result(has_swap_chain_support)
    implicit none

    ! VkPhysicalDevice
    integer(c_int64_t), intent(in), value :: physical_device
    ! VkSurfaceKHR
    integer(c_int64_t), intent(in), value :: window_surface
    logical(c_bool) :: has_swap_chain_support
    type(forvulkan_swap_chain_support_details), intent(inout), pointer :: swap_chain_support_details
    integer(c_int32_t) :: format_count, present_mode_count
    type(vk_surface_format_khr), pointer :: surface_format_pointer

    has_swap_chain_support = .true.

    print"(A)","[Vulkan]: Checking for swap chain support."

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

    print"(A)","[Vulkan]: Found ["//int_to_string(format_count)//"] supported physical device surface formats."

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

    print"(A)","[Vulkan]: Found ["//int_to_string(present_mode_count)//"] supported physical device present modes."

    ! Again, if it does, we can get all of them.
    swap_chain_support_details%present_modes = new_vec(sizeof(0_4), 0_8)
    call swap_chain_support_details%present_modes%resize(int(present_mode_count, c_int64_t), 0_4)

    if (vk_get_physical_device_surface_present_modes_khr(physical_device, window_surface, present_mode_count, swap_chain_support_details%present_modes%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to get avilable physical device surface present modes."
    end if
  end function query_swap_chain_support


end module vulkan_driver_query_swap_chain_support
