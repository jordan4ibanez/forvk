module vulkan_driver_ensure_extensions_present
  use, intrinsic :: iso_c_binding
  use :: vector
  use :: string_f90
  use :: glfw
  use :: forvulkan
  use :: forvulkan_parameters
  use :: vulkan_driver_create_required_extensions
  implicit none


contains



  subroutine ensure_extensions_present(DEBUG_MODE)
    implicit none

    logical(c_bool), intent(in), value :: DEBUG_MODE
    type(vec) :: required_extensions
    integer(c_int) :: result, extension_count
    type(vec) :: available_extensions
    type(vk_extension_properties) :: blank
    integer(c_int) :: i, j
    type(c_ptr), pointer :: raw_c_ptr_ptr
    type(vk_extension_properties), pointer :: extension_properties
    character(len = :, kind = c_char), pointer :: temp_string_pointer
    character(len = :, kind = c_char), pointer :: temp
    logical(c_bool) :: found

    print"(A)","[Vulkan]: Gathering available extensions."

    call create_required_extensions(required_extensions, DEBUG_MODE)

    result = vk_enumerate_instance_extension_properties(c_null_ptr, extension_count, c_null_ptr)

    if (result /= VK_SUCCESS) then
      error stop "[Vulkan]: Failed to enumrate instance extension properties. Error code ["//int_to_string(result)//"]"
    end if

    available_extensions = new_vec(sizeof(blank), int(extension_count, c_int64_t))
    call available_extensions%resize(int(extension_count, c_int64_t), blank)

    result = vk_enumerate_instance_extension_properties(c_null_ptr, extension_count, available_extensions%get(1_8))

    print"(A)","[Vulkan]: Ensuring required extensions are present."

    ! Iterate all required extensions.

    do j = 1,int(required_extensions%size())

      found = .false.

      call c_f_pointer(required_extensions%get(int(j, c_int64_t)), raw_c_ptr_ptr)
      temp_string_pointer => string_from_c(raw_c_ptr_ptr)

      ! Iterate all available extensions.
      do i = 1,int(extension_count)

        ! Transfer the VkExtensionProperties pointer into Fortran.
        call c_f_pointer(available_extensions%get(int(i, c_int64_t)), extension_properties)

        ! Let us convert the extension name from a char array into a string.
        temp => character_array_to_string_pointer(extension_properties%extension_name)

        ! And check if the strings are equal.
        if (temp_string_pointer == temp) then
          found = .true.
          deallocate(temp)
          exit
        end if

        deallocate(temp)
      end do

      ! We can't continue if a required extensions isn't present.
      if (found) then
        print"(A)","[Vulkan]: Found required extension ["//temp_string_pointer//"]"
      else
        error stop "[Vulkan] Error: Could not find required extension ["//temp_string_pointer//"]"
      end if
    end do

    call available_extensions%destroy()
    call required_extensions%destroy()

    print"(A)","[Vulkan]: All required extensions are present."
  end subroutine ensure_extensions_present


end module vulkan_driver_ensure_extensions_present
