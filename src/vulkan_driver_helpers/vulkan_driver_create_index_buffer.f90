module vulkan_driver_create_index_buffer
  use, intrinsic :: iso_c_binding
  use :: vulkan_driver_create_buffer
  use :: vulkan_driver_copy_buffer
  use :: forvulkan
  implicit none


contains


  subroutine create_index_buffer(physical_device, logical_device, indices)
    implicit none

    type(vk_physical_device), intent(in), value :: physical_device
    type(vk_device), intent(in), value :: logical_device
    integer(c_int32_t), dimension(:) :: indices
    type(vk_device_size) :: buffer_size
    type(vk_buffer) :: staging_buffer
    type(vk_device_memory) :: staging_buffer_memory

    buffer_size%data = sizeof(indices(1)) * size(indices)

    call create_buffer(physical_device, logical_device, buffer_size, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, ior(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT, VK_MEMORY_PROPERTY_HOST_COHERENT_BIT), staging_buffer, staging_buffer_memory)


  end subroutine create_index_buffer


  subroutine totally_not_memcpy_index(data, vertices)
    implicit none

    type(c_ptr), intent(in), value :: data
    type(vertex), dimension(:), intent(in) :: vertices
    type(vertex), dimension(:), pointer :: data_in_buffer

    call c_f_pointer(data, data_in_buffer, [size(vertices)])
    data_in_buffer = vertices
  end subroutine totally_not_memcpy_index

end module vulkan_driver_create_index_buffer
