module temp_vertex_understanding
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vector_3f
  use :: vector_2f
  implicit none



  type :: vertex
    type(vec2f) :: position
    type(vec3f) :: color
  contains
    procedure, nopass :: get_binding_description => vertex_get_binding_description
    procedure, nopass :: get_attribute_descriptions => vertex_get_attribute_descriptions
  end type vertex


contains


  function vertex_get_binding_description() result(binding_description)
    implicit none

    type(vk_vertex_input_binding_description) :: binding_description

    binding_description%binding = 0
    binding_description%stride = sizeof(vertex())
    binding_description%input_rate = VK_VERTEX_INPUT_RATE_VERTEX
  end function vertex_get_binding_description


  function vertex_get_attribute_descriptions() result(attribute_descriptions)
    implicit none

    type(vk_vertex_input_attribute_description), dimension(2) :: attribute_descriptions

    ! There is no offsetof in gfortran (yet) so we will have to calculate offset ourselves. :D
    ! You can use fpm to make a small project and recalculate this with sizeof() and break your struct down.

    !? Element 1.
    attribute_descriptions(1)%binding = 0
    attribute_descriptions(1)%location = 0
    attribute_descriptions(1)%format = vk_format(VK_FORMAT_R32G32_SFLOAT)
    ! 0 bytes = starting point.
    attribute_descriptions(1)%offset = 0

    !? Element 2.
    attribute_descriptions(2)%binding = 0
    attribute_descriptions(2)%location = 1
    attribute_descriptions(2)%format = vk_format(VK_FORMAT_R32G32B32_SFLOAT)
    ! 3 elements * 4 byte float = 12 bytes
    attribute_descriptions(2)%offset = 12
  end function


end module temp_vertex_understanding
