module vulkan_driver_create_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vulkan_vertex
  implicit none

contains


  subroutine create_buffer(logical_device, device_size, usage, properties, buffer, buffer_memory, vertices)
    implicit none

    type(vk_device), intent(in), value :: logical_device
    ! VkBufferUsageFlags
    integer(c_int32_t), intent(in), value :: usage
    ! VkMemoryPropertyFlags
    integer(c_int32_t), intent(in), value :: properties
    type(vk_buffer), intent(inout) :: buffer
    type(vk_device_memory), intent(inout) :: buffer_memory
    type(vertex), dimension(:), intent(in) :: vertices
    ! VkDeviceSize
    integer(c_int64_t), intent(in), value :: device_size
    type(vk_buffer_create_info), target :: buffer_info

    buffer_info%s_type = VK_STRUCTURE_TYPE%BUFFER_CREATE_INFO
    buffer_info%size = sizeof(vertices(1)) * size(vertices)
    buffer_info%usage = VK_BUFFER_USAGE_VERTEX_BUFFER_BIT
    buffer_info%sharing_mode = VK_SHARING_MODE_EXCLUSIVE

    if (vk_create_buffer(logical_device, c_loc(buffer_info), c_null_ptr, buffer) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create buffer."
    end if

  end subroutine create_buffer


end module vulkan_driver_create_buffer
