module SPEDASIRBEMExt

import IRBEM
import SPEDAS
using SPEDAS: resolve_dim, times

function SPEDAS._irbem_cotrans(A, in, out, t = times(A); dim = nothing)
    data = resolve_dim(A, dim) == 1 ?
        IRBEM.transform(t, A', in, out)' :
        IRBEM.transform(t, A, in, out)
    return SPEDAS._rebuild_data(A, data)
end

end
