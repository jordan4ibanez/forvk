module temp_vertex_understanding
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vector_3f
  implicit none

  type, bind(c) :: vertex
    type(vec3f) :: position
  end type vertex


contains



end module temp_vertex_understanding
