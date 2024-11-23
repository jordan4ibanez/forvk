module vulkan_driver_create_vertex_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: temp_vertex_understanding
  implicit none


contains


  subroutine create_vertex_buffer(logical_device, vertex_data, vertex_buffer)
    implicit none

    type(vk_device), intent(in), value :: logical_device
    type(vertex), dimension(:), intent(in) :: vertex_data
    type(vk_buffer), intent(inout) :: vertex_buffer
    type(vk_buffer_create_info), target :: buffer_info

    buffer_info%s_type = VK_STRUCTURE_TYPE%BUFFER_CREATE_INFO
    buffer_info%size = sizeof(vertex_data(1)) * size(vertex_data)
    buffer_info%usage = VK_BUFFER_USAGE_VERTEX_BUFFER_BIT
    buffer_info%sharing_mode = VK_SHARING_MODE_EXCLUSIVE

    if (vk_create_buffer(logical_device, c_loc(buffer_info), c_null_ptr, vertex_buffer) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create buffer."
    end if
  end subroutine create_vertex_buffer


end module vulkan_driver_create_vertex_buffer
