module vulkan_driver_create_physical_device_extensions
  use, intrinsic :: iso_c_binding
  use :: vector
  use :: forvulkan
  use :: forvulkan_parameters
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
    type(c_ptr) :: raw_c_ptr

    required_device_extensions = new_vec(sizeof(c_null_ptr), 0_8)

    allocate(character(len = len(VK_KHR_SWAPCHAIN_EXTENSION_NAME), kind = c_char) :: required_extension)
    required_extension = VK_KHR_SWAPCHAIN_EXTENSION_NAME

    ! This is done like this so we don't blow up gfortran.
    raw_c_ptr = c_loc(required_extension)
    call required_device_extensions%push_back(raw_c_ptr)

    call required_device_extensions%shrink_to_fit()
  end subroutine create_required_physical_device_extensions


end module vulkan_driver_create_physical_device_extensions
