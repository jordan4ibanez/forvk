module vulkan_driver_update_uniform_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: matrix_4f
  use :: vulkan_driver_uniform_buffer
  use :: math_helpers
  implicit none

  ! I don't feel like bringing in vector so this will just run as fast as it will.
  real(c_float) :: time = 0.0

contains


  subroutine update_uniform_buffer(current_image, uniform_buffers_mapped, swapchain_extent)
    implicit none

    integer(c_int64_t), intent(in), value :: current_image
    ! void * Vector (Vector of raw pointers to [currently] uniform_buffer_object)
    type(vec), intent(inout) :: uniform_buffers_mapped
    type(vk_extent_2d), intent(in) :: swapchain_extent
    type(uniform_buffer_object) :: ubo
    type(c_ptr), pointer :: raw_c_ptr_ptr
    type(uniform_buffer_object), pointer :: ubo_pointer

    time = time + 0.0005

    call ubo%camera_matrix%identity()
    call ubo%object_matrix%identity()

    call ubo%camera_matrix%perspective_left_handed(to_radians_f32(60.0), real(swapchain_extent%width) / real(swapchain_extent%height), 0.01, 1000.0, .true.)

    call ubo%object_matrix%translate(cos(time / 2.0), 0.0, 3.0)
    call ubo%object_matrix%rotate_y(time)

    call c_f_pointer(uniform_buffers_mapped%get(current_image), raw_c_ptr_ptr)
    call c_f_pointer(raw_c_ptr_ptr, ubo_pointer)

    ! We have memcpy at home.
    ubo_pointer%camera_matrix = ubo%camera_matrix
    ubo_pointer%object_matrix = ubo%object_matrix
  end subroutine update_uniform_buffer


end  module vulkan_driver_update_uniform_buffer
