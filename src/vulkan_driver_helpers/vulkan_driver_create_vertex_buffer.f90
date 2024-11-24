module vulkan_driver_create_vertex_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vulkan_vertex
  use :: vulkan_driver_find_memory_type
  use :: vulkan_driver_create_buffer
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
    ! VkDeviceSize
    integer(c_int64_t) :: buffer_size
    ! void *
    type(c_ptr) :: data

    buffer_size = sizeof(vertices(1)) * size(vertices)
    call create_buffer(physical_device, logical_device, buffer_size, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT, ior(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT, VK_MEMORY_PROPERTY_HOST_COHERENT_BIT), vertex_buffer, vertex_buffer_memory, buffer_info)

    if (vk_map_memory(logical_device, vertex_buffer_memory, 0_8, buffer_info%size, 0, data) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to map memory."
    end if

    call totally_not_memcpy(data, vertices)

    call vk_unmap_memory(logical_device, vertex_buffer_memory)
  end subroutine create_vertex_buffer


  subroutine totally_not_memcpy(data, vertices)
    implicit none

    type(c_ptr), intent(in), value :: data
    type(vertex), dimension(:), intent(in) :: vertices
    type(vertex), dimension(:), pointer :: data_in_buffer

    call c_f_pointer(data, data_in_buffer, [size(vertices)])
    data_in_buffer = vertices
  end subroutine totally_not_memcpy


end module vulkan_driver_create_vertex_buffer
