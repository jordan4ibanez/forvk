module vulkan_driver_uniform_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: matrix_4f
  implicit none


  type :: uniform_buffer_object
    type(mat4f) :: model
    type(mat4f) :: view
    type(mat4f) :: proj
  end type uniform_buffer_object


end module vulkan_driver_uniform_buffer
