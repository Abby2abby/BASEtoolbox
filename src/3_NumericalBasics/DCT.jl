#---------------------------------------------------------
# Discrete Cosine Transform
#---------------------------------------------------------
function  mydctmx(n::Int)
    DC::Array{Float64,2} =zeros(n,n);
    for j=0:n-1
        DC[1,j+1]=float(1/sqrt(n));
        for i=1:n-1
            DC[i+1,j+1]=(pi*float((j+1/2)*i/n));
            DC[i+1,j+1] = sqrt(2/n).*cos.(DC[i+1,j+1])
        end
    end
    return DC
end


function uncompress(compressionIndexes, XC, DC,IDC)
    nm = size(DC[1],1)
    nk = size(DC[2],1)
    ny = size(DC[3],1)
    # POTENTIAL FOR SPEEDUP BY SPLITTING INTO DUAL AND REAL PART AND USE BLAS
    θ1 =zeros(eltype(XC),nm,nk,ny)
    for j  =1:length(XC)
        θ1[compressionIndexes[j]] = copy(XC[j])
    end
    @views for yy = 1:ny
        θ1[:,:,yy] = IDC[1]*θ1[:,:,yy]*DC[2]
    end
    @views for mm = 1:nm
        θ1[mm,:,:] = θ1[mm,:,:]*DC[3]
    end
    θ = reshape(θ1,(nm)*(nk)*(ny))
    return θ
end

function compress(compressionIndexes::AbstractArray, XU::AbstractArray,
    DC::AbstractArray,IDC::AbstractArray)
    nm, nk, ny=size(XU)
    θ   = zeros(eltype(XU),length(compressionIndexes))
    XU2 = similar(XU)
    @inbounds @views for m = 1:nm
        XU2[m,:,:] = DC[2]*XU[m,:,:]*IDC[3]
    end
    @inbounds @views  for y = 1:ny
        XU2[:,:,y] = DC[1]*XU2[:,:,y]
    end
    θ = XU2[compressionIndexes]
    return θ
end
