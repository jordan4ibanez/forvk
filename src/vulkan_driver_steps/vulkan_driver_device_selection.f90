module vulkan_driver_device_selection
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vector
  use :: vulkan_driver_find_queue_families
  use, intrinsic :: iso_c_binding
  implicit none


contains


  subroutine select_physical_device(vulkan_instance, physical_device)
    implicit none

    ! VkInstance
    integer(c_int64_t), intent(in), value :: vulkan_instance
    ! VkPhysicalDevice
    integer(c_int64_t), intent(inout) :: physical_device
    integer(c_int32_t) :: device_count, i
    ! c_int64_t [VkPhysicalDevice]
    type(vec) :: available_devices
    ! VkPhysicalDevice *
    integer(c_int64_t), pointer :: device_pointer
    character(len = :, kind = c_char), pointer :: device_name

    print"(A)","[Vulkan]: Selecting physical device."

    ! First, we will get the available devices from Vulkan.
    if (vk_enumerate_physical_devices(vulkan_instance, device_count, c_null_ptr) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to enumerate physical devices."
    end if

    if (device_count == 0) then
      ! todo: in Formine we will make this clean up then run the OpenGL driver. :)
      error stop "[Vulkan] Error: No GPU with Vulkan support available."
    end if

    ! Now, create the vector to store the data.
    available_devices = new_vec(sizeof(physical_device), int(device_count, c_int64_t))
    call available_devices%resize(int(device_count, c_int64_t), physical_device)

    ! Here we're passing in the underlying C array.
    if (vk_enumerate_physical_devices(vulkan_instance, device_count, available_devices%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to enumerate physical devices."
    end if

    ! Let's find a device that's suitable.
    device_search: do i = 1,int(available_devices%size())
      ! We're inlining transfering the device pointer from the interal C array into Fortran.
      call c_f_pointer(available_devices%get(int(i, c_int64_t)), device_pointer)

      ! We found it, woo. That's our physical device.
      ! todo: Make a menu option to select another physical device.
      if (device_is_suitable(device_pointer, device_name)) then
        physical_device = device_pointer
        exit device_search
      end if
    end do device_search

    if (physical_device == VK_NULL_HANDLE) then
      error stop "[Vulkan] Error: No suitable GPU available."
    else
      ! todo: can put these devices in some kind of array instead of just destroying the pointers.
      print"(A)","[Vulkan]: Using physical device ["//device_name//"]"
      deallocate(device_name)
    end if
  end subroutine select_physical_device


  function device_is_suitable(device_pointer, device_name) result(suitable)
    implicit none

    ! VkPhysicalDevice
    integer(c_int64_t), intent(inout), pointer :: device_pointer
    character(len = :, kind = c_char), intent(inout), pointer :: device_name
    logical(c_bool) :: suitable
    type(vk_physical_device_properties), pointer :: device_properties
    type(vk_physical_device_features), pointer :: device_features
    integer(c_int32_t) :: i, device_name_length
    type(forvulkan_queue_family_index) :: queue_index

    suitable = .false.

    allocate(device_properties)
    call vk_get_physical_device_properties(device_pointer, c_loc(device_properties))

    allocate(device_features)
    call vk_get_physical_device_features(device_pointer, c_loc(device_features))

    ! Check if we have the bare minimum to run with.
    ! todo: score GPUs.
    ! todo: device_properties%device_type == VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU .and.
    ! todo: https://vulkan-tutorial.com/Drawing_a_triangle/Setup/Physical_devices_and_queue_families
    ! todo: Base device suitability checks
    ! if (device_features%geometry_shader == VK_TRUE) then
    suitable = .true.
    ! end if

    ! todo: this should probably just go into a string pointer map.
    ! Get the device name length.
    do i = 1,VK_MAX_PHYSICAL_DEVICE_NAME_SIZE
      if (device_properties%device_name(i) == achar(0)) then
        device_name_length = i - 1
        exit
      end if
    end do

    ! Now copy it over.
    !! fixme: This is a memory leak when we start checking multiple gpus. :D
    allocate(character(len = device_name_length, kind = c_char) :: device_name)
    do i = 1,device_name_length
      device_name(i:i) = device_properties%device_name(i)
    end do

    print"(A)","[Vulkan]: Found physical device ["//device_name//"]"

    queue_index = find_queue_families(device_pointer)

    if (queue_index%has_value) then
      print"(A)","[Vulkan]: Device has graphical queue family."
    else
      print"(A)", "[Vulkan]: Device has no graphical queue family."
      suitable = .false.
    end if

    deallocate(device_properties)
    deallocate(device_features)
  end function device_is_suitable


end module vulkan_driver_device_selection
