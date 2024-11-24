module vulkan_driver_create_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vulkan_vertex
  use :: vulkan_driver_find_memory_type
  implicit none

contains


  subroutine create_buffer(physical_device, logical_device, buffer_size, usage, properties, buffer, buffer_memory, buffer_info)
    implicit none

    type(vk_physical_device), intent(in), value :: physical_device
    type(vk_device), intent(in), value :: logical_device
    ! VkBufferUsageFlags
    integer(c_int32_t), intent(in), value :: usage
    ! VkMemoryPropertyFlags
    integer(c_int32_t), intent(in), value :: properties
    type(vk_buffer), intent(inout) :: buffer
    type(vk_device_memory), intent(inout) :: buffer_memory
    type(vk_buffer_create_info), intent(inout), target :: buffer_info
    ! VkDeviceSize
    integer(c_int64_t), intent(in), value :: buffer_size
    type(vk_memory_allocate_info), target :: alloc_info
    type(vk_memory_requirements), target :: mem_requirements

    buffer_info%s_type = VK_STRUCTURE_TYPE%BUFFER_CREATE_INFO
    buffer_info%size = buffer_size
    buffer_info%usage = usage
    buffer_info%sharing_mode = VK_SHARING_MODE_EXCLUSIVE

    if (vk_create_buffer(logical_device, c_loc(buffer_info), c_null_ptr, buffer) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create buffer."
    end if

    call vk_get_buffer_memory_requirements(logical_device, buffer, c_loc(mem_requirements))

    alloc_info%s_type = VK_STRUCTURE_TYPE%MEMORY%ALLOCATE_INFO
    alloc_info%allocation_size = mem_requirements%size
    alloc_info%memory_type_index = find_memory_type(physical_device, mem_requirements%memory_type_bits, properties)

    if (vk_allocate_memory(logical_device, c_loc(alloc_info), c_null_ptr, buffer_memory) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to allocate buffer memory."
    end if

    ! todo: put this thing into a more generic function or module, lol. This is horrible.
    if (vk_bind_buffer_memory(logical_device, buffer, buffer_memory, 0_8) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to bind buffer memory."
    end if
  end subroutine create_buffer


end module vulkan_driver_create_buffer
