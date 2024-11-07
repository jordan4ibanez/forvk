module vulkan_driver_create_debug_messenger
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  use :: string_f90
  implicit none


contains


  subroutine create_messenger_struct(messenger_create_info, DEBUG_MODE)
    implicit none

    type(vk_debug_utils_messenger_create_info_ext), intent(inout), target :: messenger_create_info!validation_create_info
    logical(c_bool), intent(in), value :: DEBUG_MODE

    if (.not. DEBUG_MODE) then
      return
    end if

    messenger_create_info%s_type = VK_STRUCTURE_TYPE%DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT
    messenger_create_info%message_severity = or(VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT, or(VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT, VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT))
    messenger_create_info%message_type = or(VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT, or(VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT, VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT))
    messenger_create_info%pfn_user_callback = c_funloc(debug_callback)
    messenger_create_info%p_user_data = c_null_ptr ! Optional.
  end subroutine create_messenger_struct


  subroutine setup_debug_messenger(debug_messenger_create_info, vulkan_instance, debug_messenger, DEBUG_MODE)
    implicit none

    type(vk_debug_utils_messenger_create_info_ext), intent(inout), pointer :: debug_messenger_create_info!validation_create_info
    integer(c_int64_t), intent(inout) :: vulkan_instance
    integer(c_int64_t), intent(inout) :: debug_messenger
    logical(c_bool), intent(in), value :: DEBUG_MODE

    ! Don't need this if we're not in debug mode.
    if (.not. DEBUG_MODE) then
      return
    end if

    print"(A)","[Vulkan]: Setting up debug messenger."

    allocate(debug_messenger_create_info)
    call create_messenger_struct(debug_messenger_create_info, DEBUG_MODE)

    if (forvulkan_create_debug_utils_messenger_ext(vulkan_instance, c_loc(debug_messenger_create_info), c_null_ptr, debug_messenger) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to set up debug messenger."
    end if
  end subroutine setup_debug_messenger


  recursive function debug_callback(message_severity, message_type, p_callback_data_ptr) result(vk_bool_32) bind(c)
    implicit none

    integer(c_int), intent(in), value :: message_severity, message_type
    ! const VkDebugUtilsMessengerCallbackDataEXT *
    type(c_ptr), intent(in), value :: p_callback_data_ptr
    integer(c_int) :: vk_bool_32
    type(vk_debug_utils_messenger_callback_data_ext), pointer :: p_callback_data

    if (.false.) then
      print*,message_severity, message_type
    end if

    call c_f_pointer(p_callback_data_ptr, p_callback_data)

    if (message_severity >= VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT) then
      ! Message is important enough to show
      ! print*,"high severity"
      error stop achar(10)//"===========================|"//achar(10)//"[Vulkan] Validation layer: |"//achar(10)//"===========================|"//achar(10)//string_from_c(p_callback_data%p_message)//achar(10)//"=========================="
    end if

    vk_bool_32 = VK_FALSE
  end function debug_callback


end module vulkan_driver_create_debug_messenger
