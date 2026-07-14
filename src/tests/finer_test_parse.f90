!< FiNeR test: INI parsing rules.
program finer_test_parse
!< Covers: full-line comments (;, #, !), inline comment stripping,
!<         multi-line continuation, multi-section detection, custom separator.
use finer, only: file_ini
use penf,  only: I4P, R4P
implicit none

type(file_ini)                :: fini
character(len=:), allocatable :: source, val, slist(:)
real(R4P),        allocatable :: arr(:)
integer(I4P)                  :: error
integer                       :: passed, total

passed = 0 ; total = 0
print '(A)', 'finer_test_parse'

source = '[section-1]'//new_line('A')//                                  &
         '; full-line comment (;)'//new_line('A')//                      &
         '# full-line comment (#)'//new_line('A')//                      &
         '! full-line comment (!)'//new_line('A')//                      &
         'option-1 = one ; inline comment'//new_line('A')//              &
         'option-2 = 2.'//new_line('A')//                                &
         '           3.'//new_line('A')//                                &
         'option-3 = bar'//new_line('A')//                               &
         '[section-2]'//new_line('A')//                                  &
         'option-1 = foo'

call fini%load(source=source)
call fini%get_sections_list(slist)

call check('section count == 2',             size(slist) == 2)

val = repeat(' ', 64)
call fini%get(section_name='section-1', option_name='option-1', val=val, error=error)
call check('valid get: no error',            error == 0)
call check('inline comment stripped',        trim(val) == 'one')

allocate(arr(1:fini%count_values(section_name='section-1', option_name='option-2')))
call fini%get(section_name='section-1', option_name='option-2', val=arr, error=error)
call check('multi-line: token count == 2',   size(arr) == 2)
call check('multi-line: first token == 2.',  abs(arr(1) - 2._R4P) < 1e-6_R4P)
call check('multi-line: second token == 3.', abs(arr(2) - 3._R4P) < 1e-6_R4P)

val = repeat(' ', 64)
call fini%get(section_name='section-2', option_name='option-1', val=val, error=error)
call check('option in second section',       trim(val) == 'foo')

call fini%free
source = '[s1]'//new_line('A')//'key : value'
call fini%load(separator=':', source=source)
val = repeat(' ', 64)
call fini%get(section_name='s1', option_name='key', val=val, error=error)
call check("custom separator ':'",           trim(val) == 'value')

call fini%free
source = '[section-3]'//new_line('A')//                                     &
         'option-1 = 1.'//new_line('A')//                                   &
         '; comment interrupting a continued value'//new_line('A')//        &
         '           2.'//new_line('A')//                                   &
         '           3. ; trailing inline comment'//new_line('A')//         &
         'option-2 = end'
call fini%load(source=source)
deallocate(arr)
allocate(arr(1:fini%count_values(section_name='section-3', option_name='option-1')))
call fini%get(section_name='section-3', option_name='option-1', val=arr, error=error)
call check('continuation across comment: token count == 3',   size(arr) == 3)
call check('continuation across comment: first token == 1.',  abs(arr(1) - 1._R4P) < 1e-6_R4P)
call check('continuation across comment: second token == 2.', abs(arr(2) - 2._R4P) < 1e-6_R4P)
call check('continuation across comment: third token == 3.',  abs(arr(3) - 3._R4P) < 1e-6_R4P)
val = repeat(' ', 64)
call fini%get(section_name='section-3', option_name='option-2', val=val, error=error)
call check('option following interrupted continuation parses', trim(val) == 'end')

call fini%free
source = '[section-4]'//new_line('A')//                                     &
         "option-1 = 1. ; comment on an intermediate continuation line"//   &
         new_line('A')//                                                    &
         '           2.'//new_line('A')//                                   &
         '           3.'
call fini%load(source=source)
deallocate(arr)
allocate(arr(1:fini%count_values(section_name='section-4', option_name='option-1')))
call fini%get(section_name='section-4', option_name='option-1', val=arr, error=error)
call check('intermediate inline comment: token count == 3',   size(arr) == 3)
call check('intermediate inline comment: first token == 1.',  abs(arr(1) - 1._R4P) < 1e-6_R4P)
call check('intermediate inline comment: second token == 2.', abs(arr(2) - 2._R4P) < 1e-6_R4P)
call check('intermediate inline comment: third token == 3.',  abs(arr(3) - 3._R4P) < 1e-6_R4P)

call summary
contains

  subroutine check(label, ok)
  character(*), intent(in) :: label
  logical,      intent(in) :: ok
  total = total + 1
  if (ok) passed = passed + 1
  if (ok) then
    write(*, '("  [PASS] ", A)') label
  else
    write(*, '("  [FAIL] ", A)') label
  end if
  end subroutine check

  subroutine summary
  write(*, '(/, "--- ", I0, "/", I0, " passed")') passed, total
  write(*, '(A, L1)') 'Are all tests passed? ', passed == total
  if (passed /= total) stop 1
  end subroutine summary

end program finer_test_parse
