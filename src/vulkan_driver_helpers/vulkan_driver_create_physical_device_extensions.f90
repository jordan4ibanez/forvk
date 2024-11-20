module vulkan_driver_create_physical_device_extensions
  use, intrinsic :: iso_c_binding
  use :: vector
  use :: forvulkan
  use :: forvulkan_parameters
  use :: string_f90
  implicit none


contains


  ! We use this to check the physical device has everything.
  ! Then we enable it in the logical device.
  ! This allows for it to be passed around by using this one function
  subroutine create_required_physical_device_extensions(required_device_extensions)
    implicit none

    ! character **
    type(vec), intent(inout) :: required_device_extensions
    character(len = :, kind = c_char), pointer :: required_extension

    required_device_extensions = new_vec(sizeof(c_null_ptr), 0_8)

    allocate(character(len = len(VK_KHR_SWAPCHAIN_EXTENSION_NAME), kind = c_char) :: required_extension)
    required_extension = VK_KHR_SWAPCHAIN_EXTENSION_NAME

    call required_device_extensions%push_back(c_loc(required_extension))

    call required_device_extensions%shrink_to_fit()
  end subroutine create_required_physical_device_extensions


  subroutine device_extensions_vec_gc(raw_c_ptr_ptr)
    implicit none

    type(c_ptr), intent(in), value :: raw_c_ptr_ptr
    type(c_ptr), pointer :: raw_c_ptr
    character(len = :, kind = c_char), pointer :: str

    print*,"hello from required physical extensions gc"

    call c_f_pointer(raw_c_ptr_ptr, raw_c_ptr)
    str => string_from_c(raw_c_ptr)

    deallocate(str)
  end subroutine device_extensions_vec_gc


end module vulkan_driver_create_physical_device_extensions
