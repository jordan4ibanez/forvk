program main
  use :: vulkan_driver
  use, intrinsic :: iso_c_binding
  implicit none

  type(vk_driver) :: drv

  call drv%init()

end program main
