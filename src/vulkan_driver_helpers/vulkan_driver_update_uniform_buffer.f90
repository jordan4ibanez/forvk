module vulkan_driver_update_uniform_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  implicit none


contains


  subroutine update_uniform_buffer(current_image)
    implicit none

    integer(c_int64_t), intent(in), value :: current_image

  end subroutine update_uniform_buffer


end  module vulkan_driver_update_uniform_buffer
