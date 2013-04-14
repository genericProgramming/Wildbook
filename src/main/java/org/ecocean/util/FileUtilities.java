/*
 * The Shepherd Project - A Mark-Recapture Framework
 * Copyright (C) 2011 Jason Holmberg
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

package org.ecocean.util;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author Giles Winstanley
 */
public class FileUtilities {
  /** SLF4J logger instance for writing log entries. */
  private static final Logger log = LoggerFactory.getLogger(FileUtilities.class);

  private FileUtilities() {}

  /**
   * Copies a file to another location.
   * @param src source file
   * @param dst destination file
   * @throws IOException if there is a problem copying the file
   */
  public static void copyFile(File src, File dst) throws IOException {
    if (src == null)
      throw new NullPointerException("Invalid source file specified: null");
    if (dst == null)
      throw new NullPointerException("Invalid destination file specified: null");
    if (!src.exists())
      throw new IOException("Invalid source file specified: " + src.getAbsolutePath());
    if (dst.exists())
      throw new IOException("Destination file already exists: " + dst.getAbsolutePath());
    BufferedInputStream in = null;
    BufferedOutputStream out = null;
    try {
      in = new BufferedInputStream(new FileInputStream(src));
      out = new BufferedOutputStream(new FileOutputStream(dst));
      byte[] b = new byte[4096];
      int len = 0;
      while ((len = in.read(b)) != -1)
        out.write(b, 0, len);
      out.flush();
    } finally {
      if (out != null) {
        try { out.close(); }
        catch (IOException ex) { log.warn(ex.getMessage(), ex); }
      }
      if (in != null) {
        try { in.close(); }
        catch (IOException ex) { log.warn(ex.getMessage(), ex); }
      }
    }
  }
}