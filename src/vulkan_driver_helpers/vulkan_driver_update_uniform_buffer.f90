module vulkan_driver_update_uniform_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: matrix_4f
  use :: vulkan_driver_uniform_buffer
  implicit none

  ! I don't feel like bringing in vector so this will just run as fast as it will.
  real(c_float) :: time = 0.0

contains


  subroutine update_uniform_buffer(current_image, uniform_buffers_mapped)
    implicit none

    integer(c_int64_t), intent(in), value :: current_image
    ! void * (C pure generic Vector)
    type(vec), intent(inout) :: uniform_buffers_mapped
    type(uniform_buffer_object) :: ubo
    type(uniform_buffer_object), pointer :: ubo_pointer

    time = time + 0.0001

    call ubo%camera_matrix%identity()
    call ubo%object_matrix%identity()

    ! todo: do things here and stuff.


    call c_f_pointer(uniform_buffers_mapped%get(current_image), ubo_pointer)

    ! We have memcpy at home.
    ubo_pointer%camera_matrix = ubo%camera_matrix
    ubo_pointer%object_matrix = ubo%object_matrix
  end subroutine update_uniform_buffer


end  module vulkan_driver_update_uniform_buffer
