module shaderc_types
  use, intrinsic :: iso_c_binding
  implicit none

  !? shaderc_include_result.
  type, bind(c) :: shaderc_include_result
    ! The name of the source file.  The name should be fully resolved
    ! in the sense that it should be a unique name in the context of the
    ! includer.  For example, if the includer maps source names to files in
    ! a filesystem, then this name should be the absolute path of the file.
    ! For a failed inclusion, this string is empty.
    ! const char*
    type(c_ptr) :: source_name
    integer(c_size_t) :: source_name_length
    ! The text contents of the source file in the normal case.
    ! For a failed inclusion, this contains the error message.
    ! const char*
    type(c_ptr) :: content
    integer(c_size_t) :: content_length
    ! User data to be passed along with this request.
    ! void*
    type(c_ptr) :: user_data
  end type shaderc_include_result


end module shaderc_types
