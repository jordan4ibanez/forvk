module vulkan_driver_select_physical_device
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vector
  use :: vulkan_driver_find_queue_families
  use :: integer32_set
  use, intrinsic :: iso_c_binding
  implicit none

  ! todo: re-tool this so we can query multiple devices and rank them.

contains


  subroutine select_physical_device(vulkan_instance, physical_device, queue_indices, window_surface)
    implicit none

    ! VkInstance
    integer(c_int64_t), intent(in), value :: vulkan_instance
    ! VkPhysicalDevice
    integer(c_int64_t), intent(inout) :: physical_device
    type(forvulkan_queue_family_indices), intent(inout) :: queue_indices
    ! VkSurfaceKHR
    integer(c_int64_t), intent(in), value :: window_surface
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
      if (device_is_suitable(device_pointer, device_name, queue_indices, window_surface)) then
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


  function device_is_suitable(device_pointer, device_name, queue_indices, window_surface) result(suitable)
    implicit none

    ! VkPhysicalDevice
    integer(c_int64_t), intent(inout), pointer :: device_pointer
    character(len = :, kind = c_char), intent(inout), pointer :: device_name
    type(forvulkan_queue_family_indices), intent(inout) :: queue_indices
    ! VkSurfaceKHR
    integer(c_int64_t), intent(in), value :: window_surface
    logical(c_bool) :: suitable
    type(vk_physical_device_properties), pointer :: device_properties
    type(vk_physical_device_features), pointer :: device_features
    integer(c_int32_t) :: i, device_name_length
    type(int32_set) :: unique_queue_families
    type(vk_device_queue_create_info) :: struct_queue_create_info
    type(vec) :: queue_create_infos
    real(c_float), pointer :: queue_priority

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

    queue_indices = find_queue_families(device_pointer, window_surface)

    ! Now, if we have all needed components, we can create the present_queue!
    if (queue_indices%graphics_family_has_value .and. queue_indices%present_family_has_value) then
      print"(A)","[Vulkan]: Device has graphical queue family and present support."

      ! Get only the unique queues.
      unique_queue_families = new_int32_set()
      call unique_queue_families%push_array([queue_indices%graphics_family, queue_indices%present_family])

      ! Iterate them.

      ! todo: move this in the parent function so we can actually destroy it.
      queue_create_infos = new_vec(sizeof(struct_queue_create_info), 0_8)

      allocate(queue_priority)
      queue_priority = 1.0

      do i = 1,unique_queue_families%size

        struct_queue_create_info%s_type = VK_STRUCTURE_TYPE%DEVICE%QUEUE_CREATE_INFO
        struct_queue_create_info%queue_family_index = i
        struct_queue_create_info%queue_count = 1
        struct_queue_create_info%p_queue_priorities = c_loc(queue_priority)

        ! Now push it into the vector.
        call queue_create_infos%push_back(struct_queue_create_info)
      end do

      call unique_queue_families%destroy()

    else
      ! No if else, we want to warn about every unsupported queue family.
      if (.not. queue_indices%graphics_family_has_value) then
        print"(A)", "[Vulkan]: Device has no graphical queue family."
      end if
      if (.not. queue_indices%present_family_has_value) then
        print"(A)", "[Vulkan]: Device has no present queue family."
      end if

      suitable = .false.
    end if



    deallocate(device_properties)
    deallocate(device_features)
  end function device_is_suitable


end module vulkan_driver_select_physical_device
