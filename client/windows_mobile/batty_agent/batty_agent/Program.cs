﻿using System;

using System.Collections.Generic;
using System.Windows.Forms;

namespace nayutaya.batty.agent
{
    static class Program
    {
        /// <summary>
        /// アプリケーションのメイン エントリ ポイントです。
        /// </summary>
        [MTAThread]
        static void Main()
        {
            Application.Run(new MainForm());
        }
    }
}