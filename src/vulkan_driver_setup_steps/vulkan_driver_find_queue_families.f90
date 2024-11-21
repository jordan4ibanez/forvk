module vulkan_driver_find_queue_families
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vector
  implicit none


contains


  function find_queue_families(physical_device, window_surface) result(queue_family_indices)
    implicit none

    ! VkPhysicalDevice
    integer(c_int64_t), intent(in), value :: physical_device
    type(vk_surface_khr), intent(in), value :: window_surface
    type(forvulkan_queue_family_indices) :: queue_family_indices
    integer(c_int32_t) :: queue_family_count, i, present_support
    ! VkQueueFamilyProperties
    type(vec) :: queue_families
    type(vk_queue_family_properties), pointer :: properties

    ! Sniff out those graphics queue families.

    print"(A)","[Vulkan]: Finding queue families."

    call vk_get_physical_device_queue_family_properties(physical_device, queue_family_count, c_null_ptr)

    allocate(properties)
    queue_families = new_vec(sizeof(properties), int(queue_family_count, c_int64_t))
    call queue_families%resize(int(queue_family_count, c_int64_t), properties)
    deallocate(properties)

    call vk_get_physical_device_queue_family_properties(physical_device, queue_family_count, queue_families%get(1_8))

    do i = 1, queue_family_count
      ! We're just straight shooting this right from C into Fortran.
      call c_f_pointer(queue_families%get(int(i, c_int64_t)), properties)

      ! Check if we can do graphics on this queue.
      if (.not. queue_family_indices%graphics_family_has_value .and. iand(properties%queue_flags, VK_QUEUE_GRAPHICS_BIT) == VK_TRUE) then
        ! Move it into C indexing.
        queue_family_indices%graphics_family = i - 1
        queue_family_indices%graphics_family_has_value = .true.
      end if

      ! Check if we can actually present on this queue.
      if (vk_get_physical_device_surface_support_khr(physical_device, i - 1, window_surface, present_support) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to get physical device surface support."
      end if

      if (.not. queue_family_indices%present_family_has_value .and. present_support == VK_TRUE) then
        ! Move it into C indexing.
        queue_family_indices%present_family = i - 1
        queue_family_indices%present_family_has_value = .true.
      end if

      ! Now if we have graphics, and we have present support, we found it.
      if (queue_family_indices%graphics_family_has_value .and. queue_family_indices%present_family_has_value) then
        exit
      end if
    end do

    call queue_families%destroy()
  end function find_queue_families


end module vulkan_driver_find_queue_families
