module vulkan_driver_update_uniform_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: matrix_4f
  use :: vulkan_driver_uniform_buffer
  implicit none

  ! I don't feel like bringing in vector so this will just run as fast as it will.
  real(c_float) :: time = 0.0

contains


  subroutine update_uniform_buffer(current_image)
    implicit none

    integer(c_int64_t), intent(in), value :: current_image
    type(uniform_buffer_object), pointer :: ubo_pointer

    time = time + 0.0001

    ! todo: do things here and stuff.


  end subroutine update_uniform_buffer


end  module vulkan_driver_update_uniform_buffer
