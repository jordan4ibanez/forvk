module vulkan_driver_create_command_pool
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vulkan_driver_find_queue_families
  implicit none


contains


  subroutine create_command_pool(physical_device, window_surface, logical_device, command_pool)
    implicit none

    type(vk_physical_device), intent(in), value :: physical_device
    type(vk_surface_khr), intent(in), value :: window_surface
    type(vk_device), intent(in), value :: logical_device
    ! VkCommandPool
    integer(c_int64_t), intent(inout) :: command_pool
    type(forvulkan_queue_family_indices) :: queue_family_indices
    type(vk_command_pool_create_info), target :: command_pool_create_info

    queue_family_indices = find_queue_families(physical_device, window_surface)

    command_pool_create_info%s_type = VK_STRUCTURE_TYPE%COMMAND_POOL_CREATE_INFO
    command_pool_create_info%flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
    command_pool_create_info%queue_family_index = queue_family_indices%graphics_family

    if (vk_create_command_pool(logical_device, c_loc(command_pool_create_info), c_null_ptr, command_pool) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create command pool."
    end if
  end subroutine create_command_pool


end module vulkan_driver_create_command_pool
