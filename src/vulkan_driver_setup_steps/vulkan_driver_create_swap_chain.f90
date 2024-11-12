module vulkan_driver_create_swap_chain
  use, intrinsic :: iso_c_binding
  use :: vector
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vulkan_driver_query_swap_chain_support
  implicit none


contains


  subroutine create_swap_chain(physical_device, window_surface)
    implicit none

    ! VkPhysicalDevice
    integer(c_int64_t), intent(in), value :: physical_device
    ! VkSurfaceKHR
    integer(c_int64_t), intent(in), value :: window_surface
    type(forvulkan_swap_chain_support_details), pointer :: swap_chain_support_details

    print"(A)","[Vulkan]: Creating swap chain."


    call select_swap_surface_format(swap_chain_support_details%formats)


  end subroutine create_swap_chain



  subroutine select_swap_surface_format(available_formats)
    implicit none

    type(vec), intent(inout) :: available_formats
    integer(c_int64_t) :: i
    type(vk_surface_format_khr), pointer :: available_format_pointer
    type(vk_surface_format_khr), pointer :: selected_format_pointer

    selected_format_pointer => null()

    print"(A)","[Vulkan]: Searching for [BGRA8] surface format availability."

    search: do i = 1,available_formats%size()
      call c_f_pointer(available_formats%get(i), available_format_pointer)

      ! We will prefer this format, BGRA8. But,
      ! TODO: look into RGBA8.
      if (available_format_pointer%format == VK_FORMAT_B8G8R8A8_SRGB .and. available_format_pointer%color_space == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR) then
        allocate(selected_format_pointer)
        selected_format_pointer%color_space = available_format_pointer%color_space
        selected_format_pointer%format = available_format_pointer%format
        print"(A)","[Vulkan]: [BGRA8] surface format is selected."
        exit search
      end if
    end do search

    ! If we didn't find any format that matched what we were looking for
    ! the selected format pointer will be null. So we can use that to our advantage.
    if (.not. associated(selected_format_pointer)) then
      ! We will just select the first thing we have available.
      print"(A)","[Vulkan]: Surface format [BGRA8] unavailable. Defaulting selection."

      call c_f_pointer(available_formats%get(1_8), available_format_pointer)
      allocate(selected_format_pointer)
      selected_format_pointer%color_space = available_format_pointer%color_space
      selected_format_pointer%format = available_format_pointer%format
    end if
  end subroutine select_swap_surface_format


end module vulkan_driver_create_swap_chain
