module vulkan_driver_create_logical_device
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vulkan_driver_find_queue_families
  use :: vector
  use :: integer32_set
  implicit none


contains


  subroutine create_logical_device(physical_device, logical_device, required_validation_layers, graphics_queue, present_queue, window_surface, DEBUG_MODE)
    implicit none

    integer(c_int64_t), intent(in), value :: physical_device
    integer(c_int64_t), intent(inout), target :: logical_device
    ! type(forvulkan_queue_family_indices), intent(in) :: queue_indices
    ! const char **
    type(vec), intent(inout) :: required_validation_layers
    ! VkQueue
    integer(c_int64_t), intent(inout) :: graphics_queue
    ! VkQueue
    integer(c_int64_t), intent(inout) :: present_queue
    ! VkSurfaceKHR
    integer(c_int64_t), intent(in), value :: window_surface
    logical(c_bool), intent(in), value :: DEBUG_MODE
    type(vk_device_queue_create_info) :: queue_create_info
    real(c_float), pointer :: queue_priority
    type(vk_physical_device_features), target :: device_features
    type(vec) :: queue_create_infos
    type(vk_device_create_info), pointer :: logical_device_create_info
    type(forvulkan_queue_family_indices) :: physical_queue_family_indices
    type(int32_set) :: unique_queue_families
    integer(c_int32_t) :: i

    physical_queue_family_indices = find_queue_families(physical_device, window_surface)

    queue_create_infos = new_vec(sizeof(queue_create_info), 0_8)

    unique_queue_families = new_int32_set()
    call unique_queue_families%push_array([physical_queue_family_indices%graphics_family, physical_queue_family_indices%present_family])

    do i = 1,unique_queue_families%size
      allocate(queue_priority)
      queue_priority = 1.0

      queue_create_info%s_type = VK_STRUCTURE_TYPE%DEVICE%QUEUE_CREATE_INFO
      queue_create_info%queue_family_index = unique_queue_families%data(i)
      queue_create_info%queue_count = 1
      queue_create_info%p_queue_priorities = c_loc(queue_priority)

      call queue_create_infos%push_back(queue_create_info)
    end do

    call unique_queue_families%destroy()

    !? Device features is left alone for now.

    allocate(logical_device_create_info)

    logical_device_create_info%s_type = VK_STRUCTURE_TYPE%DEVICE%CREATE_INFO
    logical_device_create_info%queue_create_info_count = int(queue_create_infos%size())
    logical_device_create_info%p_queue_create_infos = queue_create_infos%get(1_8)
    logical_device_create_info%p_enabled_features = c_loc(device_features)
    logical_device_create_info%enabled_extension_count = 0

    if (DEBUG_MODE) then
      logical_device_create_info%enabled_layer_count = int(required_validation_layers%size())
      ! Passing in the underlying C array.
      logical_device_create_info%pp_enabled_layer_names = required_validation_layers%get(1_8)
    else
      logical_device_create_info%enabled_layer_count = 0
    end if

    if (vk_create_device(physical_device, c_loc(logical_device_create_info), c_null_ptr, logical_device) /= VK_SUCCESS) then
      error stop "[Vulkan]: Failed to create logical device."
    end if

    call vk_get_device_queue(logical_device, physical_queue_family_indices%graphics_family, 0, graphics_queue)
    call vk_get_device_queue(logical_device, physical_queue_family_indices%present_family, 0, present_queue)

  end subroutine create_logical_device


end module vulkan_driver_create_logical_device
