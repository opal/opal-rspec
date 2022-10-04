require 'diff/lcs/hunk'

class Diff::LCS::Hunk

  def unified_diff(last = false)
    # Calculate item number range.
    s = encode("@@ -#{unified_range(:old, last)} +#{unified_range(:new, last)} @@\n")

    # Outlist starts containing the hunk of the old file. Removing an item
    # just means putting a '-' in front of it. Inserting an item requires
    # getting it from the new file and splicing it in. We splice in
    # +num_added+ items. Remove blocks use +num_added+ because splicing
    # changed the length of outlist.
    #
    # We remove +num_removed+ items. Insert blocks use +num_removed+
    # because their item numbers -- corresponding to positions in the NEW
    # file -- don't take removed items into account.
    lo, hi, num_added, num_removed = @start_old, @end_old, 0, 0

    # standard:disable Performance/UnfreezeString
    outlist = @data_old[lo..hi].map { |e| String.new("#{encode(" ")}#{e.chomp}") }
    # standard:enable Performance/UnfreezeString

    last_block = blocks[-1]

    if last
      old_missing_newline = missing_last_newline?(@data_old)
      new_missing_newline = missing_last_newline?(@data_new)
    end

    @blocks.each do |block|
      block.remove.each do |item|
        op = item.action.to_s # -
        offset = item.position - lo + num_added
        # fixed for Opal:
        outlist[offset] = encode(op) + outlist[offset][1..-1]
        num_removed += 1
      end

      if last && block == last_block && old_missing_newline && !new_missing_newline
        outlist << encode('\\ No newline at end of file')
        num_removed += 1
      end

      block.insert.each do |item|
        op = item.action.to_s # +
        offset = item.position - @start_new + num_removed
        outlist[offset, 0] = encode(op) + @data_new[item.position].chomp
        num_added += 1
      end
    end

    outlist << encode('\\ No newline at end of file') if last && new_missing_newline

    s += outlist.join(encode("\n"))

    s
  end

  def context_diff(last = false)
    s = encode("***************\n")
    s += encode("*** #{context_range(:old, ",", last)} ****\n")
    r = context_range(:new, ",", last)

    if last
      old_missing_newline = missing_last_newline?(@data_old)
      new_missing_newline = missing_last_newline?(@data_new)
    end

    # Print out file 1 part for each block in context diff format if there
    # are any blocks that remove items
    lo, hi = @start_old, @end_old
    removes = @blocks.reject { |e| e.remove.empty? }

    unless removes.empty?
      # standard:disable Performance/UnfreezeString
      outlist = @data_old[lo..hi].map { |e| String.new("#{encode("  ")}#{e.chomp}") }
      # standard:enable Performance/UnfreezeString

      last_block = removes[-1]

      removes.each do |block|
        block.remove.each do |item|
          outlist[item.position - lo] = encode(block.op) + outlist[item.position - lo][1..-1] # - or !
        end

        if last && block == last_block && old_missing_newline
          outlist << encode('\\ No newline at end of file')
        end
      end

      s += outlist.join(encode("\n")) + encode("\n")
    end

    s += encode("--- #{r} ----\n")
    lo, hi = @start_new, @end_new
    inserts = @blocks.reject { |e| e.insert.empty? }

    unless inserts.empty?
      # standard:disable Performance/UnfreezeString
      outlist = @data_new[lo..hi].map { |e| String.new("#{encode("  ")}#{e.chomp}") }
      # standard:enable Performance/UnfreezeString

      last_block = inserts[-1]

      inserts.each do |block|
        block.insert.each do |item|
          outlist[item.position - lo] = encode(block.op) + outlist[item.position - lo][1..-1] # + or !
        end

        if last && block == last_block && new_missing_newline
          outlist << encode('\\ No newline at end of file')
        end
      end
      s += outlist.join(encode("\n"))
    end

    s
  end

  def old_diff(_last = false)
    warn "Expecting only one block in an old diff hunk!" if @blocks.size > 1

    block = @blocks[0]

    # Calculate item number range. Old diff range is just like a context
    # diff range, except the ranges are on one line with the action between
    # them.
    s = encode("#{context_range(:old, ",")}#{OLD_DIFF_OP_ACTION[block.op]}#{context_range(:new, ",")}\n")
    # If removing anything, just print out all the remove lines in the hunk
    # which is just all the remove lines in the block.
    unless block.remove.empty?
      @data_old[@start_old..@end_old].each { |e| s += encode("< ") + e.chomp + encode("\n") }
    end

    s += encode("---\n") if block.op == "!"

    unless block.insert.empty?
      @data_new[@start_new..@end_new].each { |e| s += encode("> ") + e.chomp + encode("\n") }
    end

    s
  end


  def ed_diff(format, _last = false)
    warn "Expecting only one block in an old diff hunk!" if @blocks.size > 1

    s =
      if format == :reverse_ed
        encode("#{ED_DIFF_OP_ACTION[@blocks[0].op]}#{context_range(:old, ",")}\n")
      else
        encode("#{context_range(:old, " ")}#{ED_DIFF_OP_ACTION[@blocks[0].op]}\n")
      end

    unless @blocks[0].insert.empty?
      @data_new[@start_new..@end_new].each do |e|
        s += e.chomp + encode("\n")
      end
      s += encode(".\n")
    end
    s
  end
end
