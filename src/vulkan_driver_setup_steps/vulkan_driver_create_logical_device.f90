module vulkan_driver_create_logical_device
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vulkan_driver_find_queue_families
  use :: vector
  use :: integer32_set
  use :: vulkan_driver_create_physical_device_extensions
  use :: vulkan_driver_create_validation_layers
  implicit none


contains


  subroutine create_logical_device(physical_device, logical_device, graphics_queue, present_queue, window_surface, DEBUG_MODE)
    implicit none

    integer(c_int64_t), intent(in), value :: physical_device
    integer(c_int64_t), intent(inout), target :: logical_device
    ! type(forvulkan_queue_family_indices), intent(in) :: queue_indices
    ! VkQueue
    integer(c_int64_t), intent(inout) :: graphics_queue
    ! VkQueue
    integer(c_int64_t), intent(inout) :: present_queue
    ! VkSurfaceKHR
    integer(c_int64_t), intent(in), value :: window_surface
    logical(c_bool), intent(in), value :: DEBUG_MODE
    ! const char **
    type(vec) :: required_validation_layers
    type(vk_device_queue_create_info) :: logical_device_queue_create_info
    real(c_float), target :: queue_priority
    type(vk_physical_device_features), target :: physical_device_features
    type(vec) :: logical_device_queue_create_infos
    type(vk_device_create_info), target :: logical_device_create_info
    type(forvulkan_queue_family_indices) :: physical_queue_family_indices
    type(int32_set) :: physical_device_unique_queue_families
    integer(c_int32_t) :: i
    type(vec) :: required_physical_device_extensions

    ! Physical and logical devices can have multiple queues.
    physical_queue_family_indices = find_queue_families(physical_device, window_surface)

    logical_device_queue_create_infos = new_vec(sizeof(logical_device_queue_create_info), 0_8)

    ! We condense them down if they overlap.
    physical_device_unique_queue_families = new_int32_set()
    call physical_device_unique_queue_families%push_array([physical_queue_family_indices%graphics_family, physical_queue_family_indices%present_family])


    ! Now iterate to create the queue info.
    queue_priority = 1.0

    do i = 1,physical_device_unique_queue_families%size
      logical_device_queue_create_info%s_type = VK_STRUCTURE_TYPE%DEVICE%QUEUE_CREATE_INFO
      logical_device_queue_create_info%queue_family_index = physical_device_unique_queue_families%data(i)
      logical_device_queue_create_info%queue_count = 1
      logical_device_queue_create_info%p_queue_priorities = c_loc(queue_priority)

      call logical_device_queue_create_infos%push_back(logical_device_queue_create_info)
    end do

    call physical_device_unique_queue_families%destroy()

    !? Device features is left alone for now. I'm just putting this here to copy the C code.
    physical_device_features = vk_physical_device_features()

    ! Create the create info for the logical device.

    call create_required_physical_device_extensions(required_physical_device_extensions)

    logical_device_create_info%s_type = VK_STRUCTURE_TYPE%DEVICE%CREATE_INFO
    logical_device_create_info%queue_create_info_count = int(logical_device_queue_create_infos%size())
    logical_device_create_info%p_queue_create_infos = logical_device_queue_create_infos%get(1_8)
    logical_device_create_info%p_enabled_features = c_loc(physical_device_features)
    logical_device_create_info%enabled_extension_count = int(required_physical_device_extensions%size())
    logical_device_create_info%pp_enabled_extension_names = required_physical_device_extensions%get(1_8)

    if (DEBUG_MODE) then
      call create_required_validation_layers(required_validation_layers, DEBUG_MODE)
      logical_device_create_info%enabled_layer_count = int(required_validation_layers%size())
      ! Passing in the underlying C array.
      logical_device_create_info%pp_enabled_layer_names = required_validation_layers%get(1_8)
    else
      logical_device_create_info%enabled_layer_count = 0
    end if

    if (vk_create_device(physical_device, c_loc(logical_device_create_info), c_null_ptr, logical_device) /= VK_SUCCESS) then
      error stop "[Vulkan]: Failed to create logical device."
    end if

    ! Now we can create the graphics queues so the logical devices can control the physical device queues.
    call vk_get_device_queue(logical_device, physical_queue_family_indices%graphics_family, 0, graphics_queue)
    call vk_get_device_queue(logical_device, physical_queue_family_indices%present_family, 0, present_queue)

    call logical_device_queue_create_infos%destroy()
    call required_validation_layers%destroy()
    call required_physical_device_extensions%destroy()
  end subroutine create_logical_device


end module vulkan_driver_create_logical_device
