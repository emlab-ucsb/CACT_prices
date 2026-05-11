* Time series plot: CCA December 2026 futures (KBCZ26)
* Input:  figure/input/CCA v26 Dec26.csv
* Output: figure/cca_dec26_timeseries.png

clear all
set more off

* ── Project root ──────────────────────────────────────────────────────────────
local root "/Users/kylemeng/Dropbox/work/research/policy/CACT/prices"

* ── Import ────────────────────────────────────────────────────────────────────
* Rows 1–6 are Bloomberg metadata; row 7 is the variable-name header.
import delimited "`root'/figure/input/CCA v26 Dec26.csv", ///
    varnames(7) encoding(UTF-8) clear

* ── Clean ─────────────────────────────────────────────────────────────────────
* Drop any rows where date is missing (e.g. trailing blank lines)
drop if missing(date)

* Convert M/D/YY string to Stata daily date
gen date2 = date(date, "MDY", 2099)
format date2 %td
drop date
rename date2 date

* Sort chronologically
sort date

* ── Time-series setup ─────────────────────────────────────────────────────────
tsset date, daily

* ── Plot ──────────────────────────────────────────────────────────────────────
set scheme plotplain

local d45    = daily("20jan2026", "DMY")
local d15    = daily("14apr2026", "DMY")
local dab    = daily("13sep2025", "DMY")
local dstart = daily("31dec2024", "DMY")
local dend   = daily("31apr2026", "DMY")
local pf     = 27.94
local pf_y   = `pf' + 0.35

quietly summarize px_last
local ymid    = (r(max) + r(min)) / 2 + 4
local d45_lbl = `d45' + 6
local d15_lbl = `d15' + 6
local dab_lbl = `dab' + 6

* Build list of 1st-of-month dates from Jan 2025 through May 2026
local xlabs
forval ym = `=ym(2025,1)'/`=ym(2026,5)' {
    local xlabs `xlabs' `=dofm(`ym')'
}

twoway line px_last date,                                                      ///
    title("California Carbon Allowance Vintage 2026 Future (December 2026 delivery)")         ///
    xtitle("")                                                                  ///
    ytitle("Allowance price ($)")                                             ///
    xlabel(`xlabs', format(%tdMon_CCYY) angle(45))                             ///
    ylabel(, format(%9.2f) nogrid)                                                     ///
    xscale(range(`dstart' `dend'))                                             ///
    xline(`d45', lcolor(red) lpattern(solid))                                  ///
    xline(`d15', lcolor(red) lpattern(solid))                                  ///
    xline(`dab', lcolor(red) lpattern(solid))                                  ///
    yline(`pf',  lcolor(gs8) lpattern(dash))                                   ///
    text(`pf_y' `dstart' "Price floor", placement(e) size(small))         ///
    text(`ymid' `d45_lbl' "45-day amendments", orientation(rvertical) size(small)) ///
    text(`ymid' `d15_lbl' "15-day amendments", orientation(rvertical) size(small)) ///
    text(`ymid' `dab_lbl' "AB1207 passed",     orientation(rvertical) size(small)) ///
    caption("Source: Intercontinental Exchange. Graph by Kyle Meng and Jordan Wingenroth, UCSB Environmental Markets Lab (emLab).", ///
            position(5) justification(right) size(vsmall))

graph export "`root'/figure/output/fig_price_dec26.png", ///
    replace width(1400)
