module vulkan_driver_create_extensions
  use, intrinsic :: iso_c_binding
  use :: vector
  use :: string_f90
  use :: glfw
  use :: forvulkan
  use :: forvulkan_parameters
  implicit none


contains


  subroutine create_required_extensions(required_extensions, DEBUG_MODE)
    implicit none

    type(vec), intent(inout) :: required_extensions
    logical(c_bool), intent(in), value :: DEBUG_MODE
    integer(c_int) :: glfw_extension_count
    type(c_ptr) :: c_glfw_extension_array_pointer
    character(len = :, kind = c_char), pointer :: temp, output
    type(c_ptr), dimension(:), pointer :: c_extension_name_pointer_array
    integer(c_int) :: i
    ! type(c_ptr), pointer :: raw_c_ptr

    print"(A)","[Vulkan]: Gathering required GLFW extensions."

    c_glfw_extension_array_pointer = glfw_get_required_instance_extensions(glfw_extension_count)

    ! Grabble the extension string pointers from C.
    temp => null()
    required_extensions = new_vec(sizeof(c_null_ptr), 0_8)

    call c_f_pointer(c_glfw_extension_array_pointer, c_extension_name_pointer_array, [glfw_extension_count])

    ! Shove all those char pointers into the vector's heap.
    do i = 1,glfw_extension_count
      temp => string_from_c(c_extension_name_pointer_array(i))
      allocate(character(len = len(temp)+1, kind = c_char) :: output)
      output = temp//achar(0)

      call required_extensions%push_back(c_loc(output))
    end do

    print"(A)","[Vulkan]: Creating required GLFW extensions."

    ! We need this for it to work in MoltenVK.
    allocate(character(len = len(VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME), kind = c_char) :: output)
    output = VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME
    call required_extensions%push_back(c_loc(output))

    ! We need this for debug messaging in debug mode.

    if (DEBUG_MODE) then
      allocate(character(len = len(VK_EXT_DEBUG_UTILS_EXTENSION_NAME), kind = c_char) :: output)
      output = VK_EXT_DEBUG_UTILS_EXTENSION_NAME
      call required_extensions%push_back(c_loc(output))
    end if
  end subroutine create_required_extensions


  subroutine ensure_extensions_present(required_extensions)
    implicit none

    type(vec), intent(inout) :: required_extensions
    integer(c_int) :: result, extension_count
    type(vec) :: available_extensions_array
    type(vk_extension_properties) :: blank
    integer(c_int) :: i, j, k, prop_length
    type(c_ptr), pointer :: raw_c_ptr_ptr
    type(vk_extension_properties), pointer :: extension_properties
    character(len = :, kind = c_char), pointer :: temp_string_pointer
    character(len = :, kind = c_char), allocatable :: temp
    logical(c_bool) :: found

    print"(A)","[Vulkan]: Gathering available extensions."

    result = vk_enumerate_instance_extension_properties(c_null_ptr, extension_count, c_null_ptr)

    if (result /= VK_SUCCESS) then
      error stop "[Vulkan]: Failed to enumrate instance extension properties. Error code ["//int_to_string(result)//"]"
    end if

    available_extensions_array = new_vec(sizeof(blank), int(extension_count, c_int64_t))
    call available_extensions_array%resize(int(extension_count, c_int64_t), blank)

    result = vk_enumerate_instance_extension_properties(c_null_ptr, extension_count, available_extensions_array%get(1_8))

    print"(A)","[Vulkan]: Ensuring required extensions are present."

    ! Iterate all required extensions.

    do j = 1,int(required_extensions%size())

      found = .false.

      call c_f_pointer(required_extensions%get(int(j, c_int64_t)), raw_c_ptr_ptr)
      temp_string_pointer => string_from_c(raw_c_ptr_ptr)

      ! Iterate all available extensions.
      do i = 1,int(extension_count)

        ! Transfer the VkExtensionProperties pointer into Fortran.
        call c_f_pointer(available_extensions_array%get(int(i, c_int64_t)), extension_properties)

        ! Find the length of the character array.
        do k = 1,VK_MAX_EXTENSION_NAME_SIZE
          if (extension_properties%extension_name(k) == achar(0)) then
            prop_length = k - 1
            exit
          end if
        end do

        ! Now copy it into a string.
        allocate(character(len = prop_length, kind = c_char) :: temp)

        do k = 1,prop_length
          temp(k:k) = extension_properties%extension_name(k)
        end do

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

    print"(A)","[Vulkan]: All required extensions are present."
  end subroutine ensure_extensions_present


end module vulkan_driver_create_extensions
