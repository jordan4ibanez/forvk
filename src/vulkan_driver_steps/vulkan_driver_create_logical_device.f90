module vulkan_driver_create_logical_device
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vector
  implicit none


contains


  subroutine create_logical_device(physical_device, logical_device, queue_indices, required_validation_layers, graphics_queue,  queue_create_infos, DEBUG_MODE)
    implicit none

    integer(c_int64_t), intent(in), value :: physical_device
    integer(c_int64_t), intent(inout), target :: logical_device
    type(forvulkan_queue_family_indices), intent(in) :: queue_indices
    ! const char **
    type(vec), intent(inout) :: required_validation_layers
    integer(c_int64_t), intent(inout), target :: graphics_queue
    ! VkDeviceQueueCreateInfo
    type(vec), intent(inout) :: queue_create_infos
    logical(c_bool), intent(in), value :: DEBUG_MODE
    type(vk_device_queue_create_info), pointer :: logical_device_queue_create_info
    real(c_float), target :: queue_priority
    type(vk_physical_device_features), pointer :: device_features
    type(vk_device_create_info), pointer :: logical_device_create_info

    allocate(logical_device_queue_create_info)

    logical_device_queue_create_info%s_type = VK_STRUCTURE_TYPE%DEVICE%QUEUE_CREATE_INFO
    logical_device_queue_create_info%queue_family_index = queue_indices%graphics_family
    logical_device_queue_create_info%queue_count = 1

    queue_priority = 1.0
    logical_device_queue_create_info%p_queue_priorities = c_loc(queue_priority)

    allocate(device_features)
    ! Leaving device_features at defaults for now.

    allocate(logical_device_create_info)

    logical_device_create_info%s_type = VK_STRUCTURE_TYPE%DEVICE%CREATE_INFO
    logical_device_create_info%p_queue_create_infos = c_loc(logical_device_queue_create_info)
    logical_device_create_info%queue_create_info_count = 1
    logical_device_create_info%p_enabled_features = c_loc(device_features)

    logical_device_create_info%enabled_extension_count = 0

    if (DEBUG_MODE) then
      logical_device_create_info%enabled_layer_count = int(required_validation_layers%size())
      ! Passing in the underlying C array.
      logical_device_create_info%pp_enabled_layer_names = required_validation_layers%get(1_8)
    else
      logical_device_create_info%enabled_layer_count = 0
    end if

    if (vk_create_device(physical_device, c_loc(logical_device_create_info), c_null_ptr, c_loc(logical_device)) /= VK_SUCCESS) then
      error stop "[Vulkan]: Failed to create logical device."
    end if

    call vk_get_device_queue(logical_device, queue_indices%graphics_family, 0, graphics_queue)
  end subroutine create_logical_device


end module vulkan_driver_create_logical_device
