module vulkan_driver_create_required_extensions
  use, intrinsic :: iso_c_binding
  use :: vector
  use :: forvulkan
  use :: forvulkan_parameters
  use :: glfw
  use :: string_f90
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
    required_extensions = new_vec(sizeof(c_null_ptr), 0_8, required_extensions_vec_gc)

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


  subroutine required_extensions_vec_gc(raw_c_ptr_ptr)
    implicit none

    type(c_ptr), intent(in), value :: raw_c_ptr_ptr
    type(c_ptr), pointer :: raw_c_ptr
    character(len = :, kind = c_char), pointer :: str

    print*,"hello from required extension vec gc"

    call c_f_pointer(raw_c_ptr_ptr, raw_c_ptr)
    str => string_from_c(raw_c_ptr)

    deallocate(str)
  end subroutine required_extensions_vec_gc


end module vulkan_driver_create_required_extensions
