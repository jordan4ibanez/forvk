module vulkan_driver_create_index_buffer
  use, intrinsic :: iso_c_binding
  use :: vulkan_driver_create_buffer
  use :: vulkan_driver_copy_buffer
  use :: forvulkan
  implicit none


contains


  subroutine create_index_buffer(indices)
    implicit none

    integer(c_int32_t), dimension(:) :: indices
    type(vk_device_size) :: buffer_size
    type(vk_buffer) :: staging_buffer
    type(vk_device_memory) :: staging_buffer_memory

    buffer_size%data = sizeof(indices(1)) * size(indices)





  end subroutine create_index_buffer

end module vulkan_driver_create_index_buffer
