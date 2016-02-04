table = require './table'

fs = require 'fs'

bmp = require 'bmp-js'

text_dict = {
  'upper': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ   ?'
  'lower': 'abcdefghijklmnopqrstuvwxyz   ?'
  'mixed': '0123456789&udu9,:#-.$/+%*=^     '
  'punct': ';<>@[\\]_`~!udu9,:\n-.$/"|*()?{}\' '
}

TFind = (K, BB) ->
  BB = parseInt BB
  i = 0
  while i < table.length
    break if table[i][K] is BB
    ++i
  i

module.exports = (filename, req, res) ->
  ``var u``
  bmpBuffer = fs.readFileSync filename
  bmpData = bmp.decode bmpBuffer
  buff = []
  str = ''
  i = void
  j = void
  k = void
  i = 0
  k = 0
  while i < bmpData.data.length
    str += if bmpData.data[i] then '0' else '1'
    ++k
    if k >= bmpData.width
      k = 0
      buff.push str
      str = ''
    i += 4
  buf = []
  i = 0
  while i < buff.length
    k = buff[i].indexOf '1'
    if k < 0
      ++i
      continue
    buf.push buff[i].substr k, buff[i].length - k * 2
    ++i
  hh = 200
  n = void
  row = void
  pos = void
  x = void
  xx = void
  j = 0
  while j < 5
    x = 2
    i = 0
    while i < buf.length
      u = buf[i][17 * 2 + 5 + j]
      if x is 2
        x = u
        n = 0
      if x is u
        ++n
      else
        x = u
        hh = n if n < hh
        n = 1
      ++i
    ++j
  buf2 = []
  B = [
    0
    0
    0
    0
  ]
  BB = void
  n0 = void
  buf5 = []
  i = 0
  while i < buf.length
    n0 = n = 0
    pos = 0
    row = []
    x = (buf[i].length / 2 - 1) / 17
    xx = 0
    BB = ''
    j = 0
    k = 0
    while j < buf[i].length
      ++k
      u = buf[i + 1][j + 1]
      ++n if u is '1'
      if u is '0' then ++n0
      if u is '0' and n
        B[pos++] = n
        BB += n
        n = 0
      if u is '1' and n0
        BB += n0
        n0 = 0
      if k >= 17
        BB += n0 if n0
        n0 = 0
        k = 0
        n = 0
        pos = 0
        if xx > 1 and xx < x - 2
          Q = void
          K = (B.0 - B.1 + B.2 - B.3 + 9) % 9 / 3
          Q = TFind K, BB
          row.push Q
          buf5.push Q
        BB = ''
        ++xx
      j += 2
    buf2.push row
    i += hh
  LenText = buf5.0
  buf5.shift 1
  val_num = 0
  pdf_mode = 'text'
  text_submode = 'upper'
  text_shift = false
  text = ''
  decode_part = (part) ->
    ret = ''
    if text_submode is 'upper'
      if part is 27
        text_submode := 'lower'
        return ''
      else
        if part is 28
          text_submode := 'mixed'
          return ''
        else
          if part is 29
            text_shift := 'punct'
            return ''
          else
            if text_shift
              ret = text_dict[text_shift][part]
              text_shift := false
            else
              ret = text_dict[text_submode][part]
      return ret
    if text_submode is 'lower'
      if part is 27
        text_shift := 'upper'
        return ''
      else
        if part is 28
          text_submode := 'mixed'
          return ''
        else
          if part is 29
            text_shift := 'punct'
          else
            if text_shift
              ret = text_dict[text_shift][part]
              text_shift := false
            else
              ret = text_dict[text_submode][part]
      return ret
    if text_submode is 'mixed'
      if part is 25
        text_submode := 'punct'
        return ''
      else
        if part is 27
          text_submode := 'lower'
          return ''
        else
          if part is 28
            text_submode := 'upper'
            return ''
          else
            if part is 29
              text_shift := 'punct'
              return ''
            else
              if text_shift
                ret = text_dict[text_shift][part]
                text_shift := false
              else
                ret = text_dict[text_submode][part]
      return ret
    if text_submode is 'punct'
      if part is 29
        text_submode := 'upper'
        return ''
      else
        if text_shift
          ret = text_dict[text_shift][part]
          text_shift := false
        else
          ret = text_dict[text_submode][part]
        return ret
    'Error'
  while i < buf5.length
    if buf5[i] is 900
      pdf_mode = 'text'
      text_submode = 'upper'
      text_shift = false
      if val_num > 0
        val = val_num
        val_num = 0
        text += val
    if buf5[i] is 902 then pdf_mode = 'num'
    if buf5[i] < 900
      if pdf_mode is 'text'
        L = buf5[i] % 30
        H = (buf5[i] - L) / 30
        text += (decode_part H) + decode_part L
      if pdf_mode is 'num'
        val_num *= 900
        val_num += buf5[i]
    ++i
  text
  
