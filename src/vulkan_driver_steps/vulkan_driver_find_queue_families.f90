module vulkan_driver_find_queue_families
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vector
  implicit none


contains


  function find_queue_families(device, window_surface) result(queue_family_index)
    implicit none

    ! VkPhysicalDevice
    integer(c_int64_t), intent(in), value :: device
    ! VkSurfaceKHR
    integer(c_int64_t), intent(in), value :: window_surface
    type(forvulkan_queue_family_index) :: queue_family_index
    integer(c_int32_t) :: queue_family_count, i, present_support
    ! VkQueueFamilyProperties
    type(vec) :: queue_families
    type(vk_queue_family_properties), pointer :: properties

    ! Sniff out those graphics queue families.

    call vk_get_physical_device_queue_family_properties(device, queue_family_count, c_null_ptr)

    allocate(properties)
    queue_families = new_vec(sizeof(properties), int(queue_family_count, c_int64_t))
    call queue_families%resize(int(queue_family_count, c_int64_t), properties)
    deallocate(properties)

    call vk_get_physical_device_queue_family_properties(device, queue_family_count, queue_families%get(1_8))

    do i = 1, queue_family_count
      ! We're just straight shooting this right from C into Fortran.
      call c_f_pointer(queue_families%get(int(i, c_int64_t)), properties)

      if (iand(properties%queue_flags, VK_QUEUE_GRAPHICS_BIT) == VK_TRUE) then
        ! Move it into C indexing.
        queue_family_index%graphics_family = i - 1
      end if

      ! Check if we can actually present on this queue.
      if (vk_get_physical_device_surface_support_khr(device, i - 1, window_surface, present_support) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to get physical device surface support."
      end if

      ! Now if we have graphics, and we have present support, we found it.
      if (present_support == VK_TRUE) then
        queue_family_index%has_value = .true.
        ! Move it into C indexing.
        queue_family_index%present_family = i - 1

        
        exit
      end if

    end do


    call queue_families%destroy()
  end function find_queue_families


end module vulkan_driver_find_queue_families
