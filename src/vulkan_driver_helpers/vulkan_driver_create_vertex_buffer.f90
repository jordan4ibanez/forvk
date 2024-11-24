module vulkan_driver_create_vertex_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vulkan_vertex
  use :: vulkan_driver_copy_buffer
  use :: vulkan_driver_create_buffer
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
    type(vk_device_size) :: buffer_size
    ! void *
    type(c_ptr) :: data
    type(vk_buffer) :: staging_buffer
    type(vk_device_memory) :: staging_buffer_memory

    buffer_size%data = sizeof(vertices(1)) * size(vertices)

    call create_buffer(physical_device, logical_device, buffer_size, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, ior(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT, VK_MEMORY_PROPERTY_HOST_COHERENT_BIT), staging_buffer, staging_buffer_memory)

    if (vk_map_memory(logical_device, staging_buffer_memory, vk_device_size(0_8), buffer_size, 0, data) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to map memory."
    end if

    call totally_not_memcpy_vertices(data, vertices)

    call vk_unmap_memory(logical_device, staging_buffer_memory)

    call create_buffer(physical_device, logical_device, buffer_size, ior(VK_BUFFER_USAGE_TRANSFER_DST_BIT, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT), VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT, vertex_buffer, vertex_buffer_memory)

    call copy_buffer(logical_device, staging_buffer, vertex_buffer, buffer_size, command_pool, graphics_queue)

    call vk_destroy_buffer(logical_device, staging_buffer, c_null_ptr)
    call vk_free_memory(logical_device, staging_buffer_memory, c_null_ptr)
  end subroutine create_vertex_buffer


  subroutine totally_not_memcpy_vertices(data, vertices)
    implicit none

    type(c_ptr), intent(in), value :: data
    type(vertex), dimension(:), intent(in) :: vertices
    type(vertex), dimension(:), pointer :: data_in_buffer

    call c_f_pointer(data, data_in_buffer, [size(vertices)])
    data_in_buffer = vertices
  end subroutine totally_not_memcpy_vertices


end module vulkan_driver_create_vertex_buffer
