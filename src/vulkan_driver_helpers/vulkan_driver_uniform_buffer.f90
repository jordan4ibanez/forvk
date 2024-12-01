module vulkan_driver_uniform_buffer
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: matrix_4f
  implicit none


  type :: uniform_buffer_object
    type(mat4f) :: camera_matrix
    type(mat4f) :: object_matrix
  end type uniform_buffer_object


end module vulkan_driver_uniform_buffer
