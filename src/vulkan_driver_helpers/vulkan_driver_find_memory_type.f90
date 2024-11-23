module vulkan_driver_find_memory_type
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  implicit none


contains

  function find_memory_type(type_filter, properties) result(t)
    implicit none

    integer(c_int32_t), intent(in), value :: type_filter


  end function find_memory_type

end module vulkan_driver_find_memory_type
