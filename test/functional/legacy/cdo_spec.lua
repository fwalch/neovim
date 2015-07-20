-- Tests for the :cdo, :cfdo, :ldo and :lfdo commands

local helpers = require('test.functional.helpers')
local feed, insert, source = helpers.feed, helpers.insert, helpers.source
local clear, execute, expect = helpers.clear, helpers.execute, helpers.expect

describe('cdo', function()
  setup(clear)

  teardown(function()
    os.remove('Xtestfile1')
    os.remove('Xtestfile2')
    os.remove('Xtestfile3')
  end)

  it('is working', function()
    execute([=[
      :call writefile(["Line1", "Line2", "Line3"], 'Xtestfile1')
      :call writefile(["Line1", "Line2", "Line3"], 'Xtestfile2')
      :call writefile(["Line1", "Line2", "Line3"], 'Xtestfile3')

      :function RunTests(cchar)
      :  let nl="\n"

      :  enew
      :  " Try with an empty list
      :  exe a:cchar . "do let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"

      :  " Populate the list and then try
      :  exe a:cchar . "getexpr ['non-error 1', 'Xtestfile1:1:3:Line1', 'non-error 2', 'Xtestfile2:2:2:Line2', 'non-error 3', 'Xtestfile3:3:1:Line3']"
      :  exe a:cchar . "do let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"

      :  " Run command only on selected error lines
      :  enew
      :  exe "2,3" . a:cchar . "do let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"
      :  " Boundary condition tests
      :  enew
      :  exe "1,1" . a:cchar . "do let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"
      :  enew
      :  exe "3" . a:cchar . "do let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"
      :  let v:errmsg=''
      :  enew
      :  exe "1,4" . a:cchar . "do let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"
      :  if v:errmsg =~# 'No more items'
      :     let g:result .= 'Range test failed' . nl
      :  else
      :     let g:result .= 'Range test passed' . nl
      :  endif
      :  " Invalid error lines test
      :  enew
      :  exe "27" . a:cchar . "do let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"
      :  exe "4,5" . a:cchar . "do let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"

      :  " Run commands from an unsaved buffer
      :  let v:errmsg=''
      :  enew
      :  setlocal modified
      :  exe "2,2" . a:cchar . "do let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"
      :  if v:errmsg =~# 'No write since last change'
      :     let g:result .= 'Unsaved file change test passed' . nl
      :  else
      :     let g:result .= 'Unsaved file change test failed' . nl
      :  endif

      :  exe "2,2" . a:cchar . "do! let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"

      :  " List with no valid error entries
      :  edit! +2 Xtestfile1
      :  exe a:cchar . "getexpr ['non-error 1', 'non-error 2', 'non-error 3']"
      :  exe a:cchar . "do let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"
      :  exe "2" . a:cchar . "do let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"

      :  " List with only one valid entry
      :  exe a:cchar . "getexpr ['Xtestfile3:3:1:Line3']"
      :  exe a:cchar . "do let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"

      :  " Tests for :cfdo and :lfdo commands
      :  exe a:cchar . "getexpr ['non-error 1', 'Xtestfile1:1:3:Line1', 'Xtestfile1:2:1:Line2', 'non-error 2', 'Xtestfile2:2:2:Line2', 'non-error 3', 'Xtestfile3:2:3:Line2', 'Xtestfile3:3:1:Line3']"
      :  exe a:cchar . "fdo let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"
      :  exe "3" . a:cchar . "fdo let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"
      :  exe "2,3" . a:cchar . "fdo let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"

      :  " List with only one valid entry
      :  exe a:cchar . "getexpr ['Xtestfile2:2:5:Line2']"
      :  exe a:cchar . "fdo let g:result .= expand('%') . ' ' . line('.') . 'L' . ' ' . col('.') . 'C' . nl"
      :endfunction

      :let result=''
      :" Tests for the :cdo quickfix list command
      :call RunTests('c')
      :let result .= "\n"
      :" Tests for the :ldo location list command
      :call RunTests('l')

      :edit! test.out
      :0put =result
    ]=])

    -- Assert buffer contents.
    expect([=[
      Xtestfile1 1L 3C
      Xtestfile2 2L 2C
      Xtestfile3 3L 1C
      Xtestfile2 2L 2C
      Xtestfile3 3L 1C
      Xtestfile1 1L 3C
      Xtestfile3 3L 1C
      Xtestfile1 1L 3C
      Xtestfile2 2L 2C
      Xtestfile3 3L 1C
      Range test passed
      Unsaved file change test passed
      Xtestfile2 2L 2C
      Xtestfile3 3L 1C
      Xtestfile1 1L 3C
      Xtestfile2 2L 2C
      Xtestfile3 2L 3C
      Xtestfile3 2L 3C
      Xtestfile2 2L 2C
      Xtestfile3 2L 3C
      Xtestfile2 2L 5C
      
      Xtestfile1 1L 3C
      Xtestfile2 2L 2C
      Xtestfile3 3L 1C
      Xtestfile2 2L 2C
      Xtestfile3 3L 1C
      Xtestfile1 1L 3C
      Xtestfile3 3L 1C
      Xtestfile1 1L 3C
      Xtestfile2 2L 2C
      Xtestfile3 3L 1C
      Range test passed
      Unsaved file change test passed
      Xtestfile2 2L 2C
      Xtestfile3 3L 1C
      Xtestfile1 1L 3C
      Xtestfile2 2L 2C
      Xtestfile3 2L 3C
      Xtestfile3 2L 3C
      Xtestfile2 2L 2C
      Xtestfile3 2L 3C
      Xtestfile2 2L 5C
      ]=])
  end)
end)
