module vulkan_driver_create_vertex_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vulkan_vertex
  use :: vulkan_driver_find_memory_type
  implicit none


contains


  subroutine create_vertex_buffer(physical_device, logical_device, vertices, vertex_buffer, vertex_buffer_memory, command_pool, graphics_queue)
    implicit none

    type(vk_physical_device), intent(in), value :: physical_device
    type(vk_device), intent(in), value :: logical_device
    type(vertex), dimension(:), intent(in) :: vertices
    type(vk_buffer), intent(inout) :: vertex_buffer
    type(vk_device_memory), intent(inout) :: vertex_buffer_memory
    type(vk_command_pool), intent(in), value :: command_pool
    type(vk_queue), intent(in), value :: graphics_queue
    ! VkDeviceSize
    integer(c_int64_t) :: buffer_size
    ! void *
    type(c_ptr) :: data
    type(vk_buffer) :: staging_buffer
    type(vk_device_memory) :: staging_buffer_memory

    buffer_size = sizeof(vertices(1)) * size(vertices)

    call create_buffer(physical_device, logical_device, buffer_size, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, ior(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT, VK_MEMORY_PROPERTY_HOST_COHERENT_BIT), staging_buffer, staging_buffer_memory)

    if (vk_map_memory(logical_device, staging_buffer_memory, 0_8, buffer_size, 0, data) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to map memory."
    end if

    call totally_not_memcpy(data, vertices)

    call vk_unmap_memory(logical_device, staging_buffer_memory)

    call create_buffer(physical_device, logical_device, buffer_size, ior(VK_BUFFER_USAGE_TRANSFER_DST_BIT, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT), VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT, vertex_buffer, vertex_buffer_memory)

    call copy_buffer(logical_device, staging_buffer, vertex_buffer, buffer_size, command_pool, graphics_queue)

    call vk_destroy_buffer(logical_device, staging_buffer, c_null_ptr)
    call vk_free_memory(logical_device, staging_buffer_memory, c_null_ptr)
  end subroutine create_vertex_buffer


  subroutine copy_buffer(logical_device, src_buffer, dst_buffer, buffer_size, command_pool, graphics_queue)
    implicit none

    type(vk_device), intent(in), value :: logical_device
    type(vk_buffer), intent(in), value :: src_buffer, dst_buffer
    ! VkDeviceSize
    integer(c_int64_t), intent(in), value :: buffer_size
    type(vk_command_pool), intent(in), value :: command_pool
    type(vk_queue), intent(in), value :: graphics_queue
    type(vk_command_buffer_allocate_info), target :: alloc_info
    type(vk_command_buffer), target :: command_buffer
    type(vk_command_buffer_begin_info), target :: begin_info
    type(vk_buffer_copy), target :: copy_region
    type(vk_submit_info), target :: submit_info

    alloc_info%s_type = VK_STRUCTURE_TYPE%COMMAND_BUFFER_ALLOCATE_INFO
    alloc_info%level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
    alloc_info%command_pool = command_pool
    alloc_info%command_buffer_count = 1

    if (vk_allocate_command_buffers(logical_device, c_loc(alloc_info), c_loc(command_buffer)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to allocate command buffer."
    end if

    begin_info%s_type = VK_STRUCTURE_TYPE%COMMAND_BUFFER_BEGIN_INFO
    begin_info%flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT

    if (vk_begin_command_buffer(command_buffer, c_loc(begin_info)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to start command buffer."
    end if

    copy_region%src_offset = 0
    copy_region%dst_offset = 0
    copy_region%size = buffer_size

    call vk_cmd_copy_buffer(command_buffer, src_buffer, dst_buffer, 1, c_loc(copy_region))

    if (vk_end_command_buffer(command_buffer) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to end command buffer."
    end if

    submit_info%s_type = VK_STRUCTURE_TYPE%SUBMIT_INFO
    submit_info%command_buffer_count = 1
    submit_info%p_command_buffers = c_loc(command_buffer)

    if (vk_queue_submit(graphics_queue, 1, c_loc(submit_info), vk_fence(VK_NULL_HANDLE)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to submit queue."
    end if

    if (vk_queue_wait_idle(graphics_queue) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to wait idle on queue."
    end if

    call vk_free_command_buffers(logical_device, command_pool, 1, c_loc(command_buffer))
  end subroutine


  subroutine totally_not_memcpy(data, vertices)
    implicit none

    type(c_ptr), intent(in), value :: data
    type(vertex), dimension(:), intent(in) :: vertices
    type(vertex), dimension(:), pointer :: data_in_buffer

    call c_f_pointer(data, data_in_buffer, [size(vertices)])
    data_in_buffer = vertices
  end subroutine totally_not_memcpy



  subroutine create_buffer(physical_device, logical_device, buffer_size, usage, properties, buffer, buffer_memory)
    implicit none

    type(vk_physical_device), intent(in), value :: physical_device
    type(vk_device), intent(in), value :: logical_device
    ! VkBufferUsageFlags
    integer(c_int32_t), intent(in), value :: usage
    ! VkMemoryPropertyFlags
    integer(c_int32_t), intent(in), value :: properties
    type(vk_buffer), intent(inout) :: buffer
    type(vk_device_memory), intent(inout) :: buffer_memory
    type(vk_buffer_create_info), target :: buffer_info
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


end module vulkan_driver_create_vertex_buffer
