module vulkan_driver_create_debug_messenger
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  use :: string_f90
  use :: vulkan_driver_create_debug_messenger_struct
  implicit none


contains


  subroutine setup_debug_messenger(vulkan_instance, debug_messenger, DEBUG_MODE)
    implicit none

    type(vk_instance), intent(in), value :: vulkan_instance
    integer(c_int64_t), intent(inout) :: debug_messenger
    logical(c_bool), intent(in), value :: DEBUG_MODE
    type(vk_debug_utils_messenger_create_info_ext), target :: debug_messenger_create_info

    ! Don't need this if we're not in debug mode.
    if (.not. DEBUG_MODE) then
      return
    end if

    print"(A)","[Vulkan]: Setting up debug messenger."

    call create_debug_messenger_struct(debug_messenger_create_info, DEBUG_MODE)

    if (forvulkan_create_debug_utils_messenger_ext(vulkan_instance, c_loc(debug_messenger_create_info), c_null_ptr, debug_messenger) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to set up debug messenger."
    end if
  end subroutine setup_debug_messenger


end module vulkan_driver_create_debug_messenger
