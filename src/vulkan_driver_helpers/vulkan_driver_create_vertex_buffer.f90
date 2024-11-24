module vulkan_driver_create_vertex_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vulkan_vertex
  use :: vulkan_driver_find_memory_type
  implicit none


contains


  subroutine create_vertex_buffer(physical_device, logical_device, vertices, vertex_buffer, vertex_buffer_memory)
    implicit none

    type(vk_physical_device), intent(in), value :: physical_device
    type(vk_device), intent(in), value :: logical_device
    type(vertex), dimension(:), intent(in) :: vertices
    type(vk_buffer), intent(inout) :: vertex_buffer
    type(vk_device_memory), intent(inout) :: vertex_buffer_memory
    type(vk_buffer_create_info), target :: buffer_info
    type(vk_memory_requirements), target :: mem_requirements
    type(vk_memory_allocate_info), target :: alloc_info

    buffer_info%s_type = VK_STRUCTURE_TYPE%BUFFER_CREATE_INFO
    buffer_info%size = sizeof(vertices(1)) * size(vertices)
    buffer_info%usage = VK_BUFFER_USAGE_VERTEX_BUFFER_BIT
    buffer_info%sharing_mode = VK_SHARING_MODE_EXCLUSIVE

    if (vk_create_buffer(logical_device, c_loc(buffer_info), c_null_ptr, vertex_buffer) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create buffer."
    end if

    call vk_get_buffer_memory_requirements(logical_device, vertex_buffer, c_loc(mem_requirements))

    alloc_info%s_type = VK_STRUCTURE_TYPE%MEMORY%ALLOCATE_INFO
    alloc_info%allocation_size = mem_requirements%size
    alloc_info%memory_type_index = find_memory_type(physical_device, mem_requirements%memory_type_bits, ior(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT, VK_MEMORY_PROPERTY_HOST_COHERENT_BIT))

    if (vk_allocate_memory(logical_device, c_loc(alloc_info), c_null_ptr, vertex_buffer_memory) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to allocate vertex buffer memory."
    end if

    ! todo: put this thing into a more generic function or module, lol. This is horrible.
    if (vk_bind_buffer_memory(logical_device, vertex_buffer, vertex_buffer_memory, 0_8) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to bind vertex buffer memory."
    end if




  end subroutine create_vertex_buffer


end module vulkan_driver_create_vertex_buffer
