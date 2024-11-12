module vulkan_driver_create_swapchain
  use, intrinsic :: iso_c_binding
  use :: vector
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vulkan_driver_query_swap_chain_support
  use :: vulkan_driver_find_queue_families
  use :: glfw
  implicit none


contains


  subroutine create_swapchain(physical_device, window_surface, swapchain)
    implicit none

    ! VkPhysicalDevice
    integer(c_int64_t), intent(in), value :: physical_device
    ! VkSurfaceKHR
    integer(c_int64_t), intent(in), value :: window_surface
    ! VkSwapchainKHR
    integer(c_int64_t), intent(inout) :: swapchain
    type(forvulkan_swapchain_support_details), pointer :: swap_chain_support_details
    type(vk_surface_format_khr), pointer :: selected_format_pointer
    ! VkPresentModeKHR
    integer(c_int32_t) :: selected_present_mode
    type(vk_extent_2d) :: selected_extent
    integer(c_int32_t) :: selected_image_count
    type(vk_swapchain_create_info_khr), target :: create_info
    type(forvulkan_queue_family_indices) :: queue_family_indices
    integer(c_int32_t), dimension(2), target :: queue_indices_array

    print"(A)","[Vulkan]: Creating swapchain."

    if (.not. query_swapchain_support(physical_device, window_surface, swap_chain_support_details)) then
      error stop "[Vulkan] Severe Error: This physical device was already tested to have swapchain support, suddenly it does not."
    end if

    selected_format_pointer => select_swap_surface_format(swap_chain_support_details%formats)
    selected_present_mode = select_swap_present_mode(swap_chain_support_details%present_modes)
    selected_extent = select_swap_extent(swap_chain_support_details%capabilities)
    selected_image_count = select_image_count(swap_chain_support_details%capabilities)

    create_info%s_type = VK_STRUCTURE_TYPE%SWAPCHAIN_CREATE_INFO_KHR
    create_info%surface = window_surface
    create_info%min_image_count = selected_image_count
    create_info%image_format = selected_format_pointer%format
    create_info%image_color_space = selected_format_pointer%color_space
    create_info%image_extent = selected_extent
    create_info%image_array_layers = 1
    create_info%image_usage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT

    queue_family_indices = find_queue_families(physical_device, window_surface)

    if (queue_family_indices%graphics_family /= queue_family_indices%present_family) then
      queue_indices_array = [queue_family_indices%graphics_family, queue_family_indices%present_family]
      create_info%image_sharing_mode = VK_SHARING_MODE_CONCURRENT
      create_info%queue_family_index_count = 2
      create_info%p_queue_family_indices = c_loc(queue_indices_array)
    else
      create_info%image_sharing_mode = VK_SHARING_MODE_EXCLUSIVE
      create_info%queue_family_index_count = 0
      create_info%p_queue_family_indices = c_null_ptr
    end if

    create_info%pre_transform = swap_chain_support_details%capabilities%current_transform
    create_info%composite_alpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
    create_info%present_mode = selected_present_mode
    create_info%old_swapchain = VK_NULL_HANDLE

    if (vk_create_swapchain_khr(physical_device, c_loc(create_info), c_null_ptr, swapchain) /= VK_SUCCESS) then

    end if

  end subroutine create_swapchain


  function select_swap_surface_format(available_formats) result(selected_format_pointer)
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
        return
      end if
    end do search


    ! So, if we didn't find anything:
    ! We will just select the first thing we have available.
    print"(A)","[Vulkan]: Surface format [BGRA8] unavailable. Defaulting selection."

    call c_f_pointer(available_formats%get(1_8), available_format_pointer)
    allocate(selected_format_pointer)
    selected_format_pointer%color_space = available_format_pointer%color_space
    selected_format_pointer%format = available_format_pointer%format
  end function select_swap_surface_format


  function select_swap_present_mode(available_present_modes) result(selected_present_mode)
    implicit none

    ! VkPresentModeKHR
    type(vec) :: available_present_modes
    ! VkPresentModeKHR
    integer(c_int32_t) :: selected_present_mode
    integer(c_int32_t), pointer :: available_present_mode_pointer
    integer(c_int64_t) :: i

    print"(A)","[Vulkan]: Searching for [mailbox] present mode."

    ! We're going to try to find mailbox support.
    do i = 1,available_present_modes%size()
      call c_f_pointer(available_present_modes%get(i), available_present_mode_pointer)
      if (available_present_mode_pointer == VK_PRESENT_MODE_MAILBOX_KHR) then
        selected_present_mode = available_present_mode_pointer
        print"(A)","[Vulkan]: [mailbox] present mode is selected."
        return
      end if
    end do

    ! If we didn't find mailbox support, just use FIFO.

    print"(A)","[Vulkan]: [mailbox] present mode not available. Defaulting to [fifo]"

    selected_present_mode = VK_PRESENT_MODE_FIFO_KHR
  end function select_swap_present_mode


  function select_swap_extent(capabilities) result(selected_extent)
    use :: math_helpers
    implicit none

    type(vk_surface_capabilities_khr), intent(in) :: capabilities
    type(vk_extent_2d) :: selected_extent

    ! If this is wayland, or macos this will get triggered.
    ! uint32 max goes into negatives using direct casting to int32.
    ! In fact, it just equals -1. :)
    if (capabilities%current_extent%width == -1) then
      ! The vulkan tutorial was using a whole bunch of variables but I'm just going to inline it and reuse.
      call glfw_get_framebuffer_size(glfw_get_window_pointer(), selected_extent%width, selected_extent%height)

      selected_extent%width = clamp_i32(selected_extent%width, capabilities%min_image_extent%width, capabilities%max_image_extent%width)
      selected_extent%height = clamp_i32(selected_extent%height, capabilities%min_image_extent%height, capabilities%max_image_extent%height)
    else
      ! If we didn't trigger that, we can just use it directly.
      selected_extent%width = capabilities%current_extent%width
      selected_extent%height = capabilities%current_extent%height
    end if
  end function select_swap_extent


  function select_image_count(capabilities) result(selected_image_count)
    implicit none

    type(vk_surface_capabilities_khr), intent(in) :: capabilities
    integer(c_int32_t) :: selected_image_count

    selected_image_count = capabilities%min_image_count + 1

    if (capabilities%max_image_count > 0 .and. selected_image_count > capabilities%max_image_count) then
      selected_image_count = capabilities%max_image_count
    end if
  end function select_image_count


end module vulkan_driver_create_swapchain
