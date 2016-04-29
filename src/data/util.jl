"""
`last_quarter_end()`

Returns the first day of the previous quarter
"""
function last_quarter_end()
    cqs = Dates.firstdayofquarter(now())     # current quarter start
    lqe = cqs - Dates.Day(1)                 # last quarter end

    Date(lqe)
end

"""
Returns a DataArray of quarter start dates between `start_date` and `end_date`.
"""
function get_quarter_ends(start_date,end_date)
    dr = start_date:end_date

    dates = recur(dr) do x
        lastdayofquarter(x) == x
    end
end

"""
Converts a collection of strings in "y-m-d" format to Dates.
"""
function stringstodates(stringarray)
    n = length(stringarray)
    dates = Vector{Date}(n)
    for i = 1:n
        dates[i] = Date(stringarray[i], "y-m-d")
    end

    dates
end

"""
Convert string in the form "YYqX", "YYYYqX", "YYYYQX", or "YYYY-QX" to a Date of the end of
the indicated quarter. `X` is in {1,2,3,4} and case of `q` is ignored.
"""
function quartertodate(string)
    if ismatch(r"^[0-9]{2}[qQ][1-4]$", string)
        year = "20"*string[1:2]
        quarter = string[end]
    elseif ismatch(r"^[0-9]{4}[qQ][1-4]$", string)
        year = string[1:4]
        quarter = string[end]
    elseif ismatch(r"^[0-9]{4}-[qQ][1-4]$", string)
        year = string[1:4]
        quarter = string[end]
    else
        throw(ParseError("Invalid format: $string"))
    end

    year = parse(Int, year)
    quarter = parse(Int, quarter)
    month = 3*quarter
    day = 1

    return Dates.lastdayofquarter(Date(year, month, day))
end


"""
`format_dates!(col, df)`

Change column `col` of dates in `df` from String to Date, and map any dates given in the
interior of a quarter to the last day of the quarter.
"""
function format_dates!(col, df)
    df[col] = stringstodates(df[col])
    map!(x->lastdayofquarter(x), df[col], df[col])
end

"""
```
na2nan!(df::DataFrame)
```

Convert all NAs in a DataFrame to NaNs.
"""
function na2nan!(df::DataFrame)
    for col in names(df)
        df[isna(df[col]), col] = NaN
    end
end

"""
```
na2nan!(df::DataFrame)
```

Convert all NAs in a DataFrame to NaNs.
"""
function na2nan!(v::DataArray)
    for i = 1:length(v)
        v[i] = isna(v[i]) ?  NaN : v[i]
    end
end
