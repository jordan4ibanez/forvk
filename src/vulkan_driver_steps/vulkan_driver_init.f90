module vulkan_driver_init
  use, intrinsic :: iso_c_binding
  use :: forvulkan_parameters
  use :: forvulkan
  use :: glfw
  use :: vector
  use :: string_f90
  implicit none


contains





  subroutine create_vulkan_instance_create_info(vulkan_create_info, app_info, required_extensions, required_validation_layers, before_init_messenger_create_info, DEBUG_MODE)
    implicit none

    type(vk_instance_create_info), intent(inout), pointer :: vulkan_create_info
    type(vk_application_info), intent(in), pointer :: app_info
    type(vec), intent(inout) :: required_extensions
    type(vec), intent(inout) :: required_validation_layers
    type(vk_debug_utils_messenger_create_info_ext), intent(inout), target :: before_init_messenger_create_info
    logical(c_bool), intent(in), value :: DEBUG_MODE

    print"(A)","[Vulkan]: Creating create info."

    allocate(vulkan_create_info)

    vulkan_create_info%flags = or(vulkan_create_info%flags, VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR)

    vulkan_create_info%s_type = VK_STRUCTURE_TYPE%INSTANCE_CREATE_INFO
    vulkan_create_info%p_application_info = c_loc(app_info)

    vulkan_create_info%enabled_extension_count = int(required_extensions%size())
    !? Note: This basically turns the vector into a pointer array.
    vulkan_create_info%pp_enabled_extension_names = required_extensions%get(1_8)

    if (DEBUG_MODE) then
      ! Passing the underlying char** array in.
      vulkan_create_info%enabled_layer_count = int(required_validation_layers%size())
      vulkan_create_info%pp_enabled_layer_names = required_validation_layers%get(1_8)

      call create_messenger_struct(before_init_messenger_create_info, DEBUG_MODE)
      vulkan_create_info%p_next = c_loc(before_init_messenger_create_info)

    else
      vulkan_create_info%enabled_layer_count = 0
    end if
  end subroutine create_vulkan_instance_create_info


  subroutine create_vulkan_instance(vulkan_create_info, vulkan_instance)
    implicit none

    ! VkInstanceCreateInfo
    type(vk_instance_create_info), intent(in), target :: vulkan_create_info
    ! VkInstance
    integer(c_int64_t), intent(inout) :: vulkan_instance
    integer(c_int) :: result


    print"(A)", "[Vulkan]: Creating instance."

    result = vk_create_instance(c_loc(vulkan_create_info), c_null_ptr, vulkan_instance)

    if (result /= VK_SUCCESS) then
      ! Shove driver check in.
      if (result == VK_ERROR_INCOMPATIBLE_DRIVER) then
        error stop "[Vulkan] Error: Failed to create Vulkan instance. Incompatible driver. Error code: ["//int_to_string(result)//"]"
      end if
      error stop "[Vulkan] Error: Failed to create Vulkan instance. Error code: ["//int_to_string(result)//"]"
    end if
  end subroutine create_vulkan_instance


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



end module vulkan_driver_init
