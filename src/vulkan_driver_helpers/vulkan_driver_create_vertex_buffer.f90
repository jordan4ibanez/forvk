module vulkan_driver_create_vertex_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vulkan_vertex
  use :: vulkan_driver_find_memory_type
  implicit none


contains


  subroutine create_vertex_buffer(physical_device, logical_device, vertex_data, vertex_buffer, vertex_buffer_memory)
    implicit none

    type(vk_physical_device), intent(in), value :: physical_device
    type(vk_device), intent(in), value :: logical_device
    type(vertex), dimension(:), intent(in) :: vertex_data
    type(vk_buffer), intent(inout) :: vertex_buffer
    type(vk_device_memory), intent(inout) :: vertex_buffer_memory
    type(vk_buffer_create_info), target :: buffer_info
    type(vk_memory_allocate_info), target :: alloc_info
    type(vk_memory_requirements), target :: mem_requirements
    type(vk_physical_device_memory_properties), target :: mem_properties

    buffer_info%s_type = VK_STRUCTURE_TYPE%BUFFER_CREATE_INFO
    buffer_info%size = sizeof(vertex_data(1)) * size(vertex_data)
    buffer_info%usage = VK_BUFFER_USAGE_VERTEX_BUFFER_BIT
    buffer_info%sharing_mode = VK_SHARING_MODE_EXCLUSIVE

    if (vk_create_buffer(logical_device, c_loc(buffer_info), c_null_ptr, vertex_buffer) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create buffer."
    end if

    call vk_get_buffer_memory_requirements(logical_device, vertex_buffer, c_loc(mem_requirements))

    alloc_info%s_type = VK_STRUCTURE_TYPE%MEMORY%ALLOCATE_INFO
    alloc_info%allocation_size =


  end subroutine create_vertex_buffer


end module vulkan_driver_create_vertex_buffer
