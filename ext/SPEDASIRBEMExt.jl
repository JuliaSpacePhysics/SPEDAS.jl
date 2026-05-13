module SPEDASIRBEMExt

import IRBEM
import SPEDAS
using SPEDAS: dimnum, times

function SPEDAS._irbem_cotrans(A, in, out, t = times(A); dim = nothing)
    data = dimnum(A, dim) == 1 ?
        IRBEM.transform(t, A', in, out)' :
        IRBEM.transform(t, A, in, out)
    return SPEDAS._rebuild_data(A, data)
end

end
