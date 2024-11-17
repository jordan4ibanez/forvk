module vulkan_driver_record_command_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  implicit none


contains


  subroutine record_command_buffer(command_buffer, image_index)
    implicit none

    ! VkCommandBuffer
    integer(c_int64_t), intent(in), value :: command_buffer
    ! uint32_t
    integer(c_int32_t) :: image_index

    

  end subroutine record_command_buffer


end module vulkan_driver_record_command_buffer
